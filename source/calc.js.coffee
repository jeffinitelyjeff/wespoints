default_input_txt = "--"

# Dates and plans should be the only things that need to be updated between
# semesters

plans = [
  [ 0,   1582 ],
  [ 105, 723  ],
  [ 135, 508  ],
  [ 165, 293  ],
  [ 210, 107  ],
  [ 285, 53   ]
]

dates =
  start: "9-3-2011"
  end: "12-18-2011"
  breaks: [
    # Fall break
    [ "10-21-2011", "10-26-2011" ],
    # Thanksgiving break
    [ "11-22-2011", "11-28-2011" ]
  ]

d_diff = (start, end) ->
  one_day = 1000 * 60 * 60 * 24

  date_ints = _.map(dates.breaks, (a) -> _.map(a, (s) -> Date.parse(s)))
  exclude = _.reduce( date_ints, ((m, i) ->
    a = start
    b = end
    x = i[0]
    y = i[1]
    if a < x
      if b < x
        0
      else if b < y
        b - x
      else
        y - x
    else if a < y
      if b < y
        b - a
      else
        y - a
    else
      0
    ), 0 )
  total = end - start

  Math.ceil (total - exclude) / one_day

round_to = (n, p) ->
  mult = Math.pow 10, p
  Math.round(n * mult) / mult

now = Date.now()
d_left = d_diff now, Date.parse(dates.end)
w_left = round_to(d_left / 7, 2)
d_so_far = d_diff Date.parse(dates.start), now
w_so_far = round_to(d_so_far / 7, 2)

# console.log "Days left: " + d_left
# console.log "Weeks left: " + w_left
# console.log "Days so far: " + d_so_far
# console.log "Weeks so far: " + w_so_far

# Get selector for the results rows
row_sel = (row_name) ->
  switch row_name
    when "left" then "#left input"
    when "left-pd" then "#left-pd input"
    when "left-pw" then "#left-pw input"
    when "used" then "#used input"
    when "used-pd" then "#used-pd input"
    when "used-pw" then "#used-pw input"
    else ""

get_row = (n) ->
  sel = row_sel n
  _.map [ $(sel).first().val(), $(sel).last().val() ], (s) -> parseInt(s)

set_row = (n, vals) ->
  sel = row_sel n
  $(sel).first().val round_to(vals[0], 1)
  $(sel).last().val round_to(vals[1], 2)

populate_with_left = (plan) ->
  left = get_row "left"
  set_row "left-pd", _.map(left, (n) -> n / d_left)
  set_row "left-pw", _.map(left, (n) -> n / w_left)

  used = [ plan[0] - left[0], plan[1] - left[1] ]
  set_row "used", used
  set_row "used-pd", _.map(used, (n) -> n / d_so_far)
  set_row "used-pw", _.map(used, (n) -> n / w_so_far)

validate = ->
  _.each $("tr.primary"), (row) ->
    m_val = $(row).find("td.m input").val()
    p_val = $(row).find("td.p input").val()
    m = m_val == "" or isNaN(m_val) or m_val < 0 or m_val > plan[0]
    p = p_val == "" or isNaN(p_val) or p_val < 0 or p_val > plan[1]
    (if m or p
      $(row).find("td.error").show()
    else
      $(row).find("td.error").hide()
    ).text(
      if m and p
        "Neither is a valid number, you jerk!"
      else if m
        "That isn't a valid number of meals"
      else if p
        "That isn't a valid number of points"
      else
        ""
    )


plan = []

go_back = (back_cell) ->
  back_cell.detach()
  $("tr.choices").removeClass("totalRow").addClass("highlight")
  $(".results").hide()
  $("tr.choices").show()
  $(row_sel "left").val(default_input_txt)
  $("#plans td.error").text("")


$(document).ready ->

  back_cell = $("#back-cell").detach()

  # we reverse the plans so they get inserted in the right order
  plans.reverse()
  # insert each plan
  _.each plans, (p, i) ->
    row = $("<tr class='choices highlight' id='plan#{plans.length-i-1}'></tr>").prependTo "table#plans tbody"
    _.each [
      $("<td class='results'>Total</td>"),
      $("<td>#{p[0]}</td>").addClass("m"),
      $("<td>#{p[1]}</td>").addClass("p")
    ], (cell) ->
      cell.appendTo row
  # reverse the plans back so we don't cause any unexpecetd behavior
  plans.reverse()

  $("#date").text (new Date).toDateString()
  $("#days-left").text d_left

  $(".secondary input").attr("disabled", true)

  $("tr.choices").click ->
    if $(this).hasClass "highlight"
      $("tr.choices.highlight").removeClass "highlight"
      $(this).addClass "totalRow"
      plan = plans[this.id.split("plan")[1]]

      # hide all the other rows
      that = this
      $("tr.choices").filter( -> this != that).hide()

      # show various stuff
      $(".results").show()
      $(this).append back_cell
      $(this).find("#back").click -> go_back(back_cell)

  $("#back").click -> go_back(back_cell)

  $(".primary input").keyup ->
    validate()
    populate_with_left plan

  $(".primary input").focus ->
    $(this).val("") if $(this).val() == default_input_txt

  $(".primary input").blur ->
    $(this).val(default_input_txt) if $(this).val() == ""

