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
d_total = d_diff Date.parse(dates.start), Date.parse(dates.end)
w_total = d_total / 7
d_left = d_diff now, Date.parse(dates.end)
w_left = d_left / 7
d_so_far = d_total - d_left
w_so_far = w_total - w_left

# console.log "Days left: " + d_left
# console.log "Weeks left: " + w_left
# console.log "Days so far: " + d_so_far
# console.log "Weeks so far: " + w_so_far

# Get selector for the results rows
row_sel = (row_name, subelem) ->
  e = switch subelem
    when "error" then ".error"
    when "ideal-m" then ".ideal-m .ideal-num"
    when "ideal-p" then ".ideal-p .ideal-num"
    else "input"
  switch row_name
    when "left" then "#left #{e}"
    when "left-pd" then "#left-pd #{e}"
    when "left-pw" then "#left-pw #{e}"
    when "used" then "#used #{e}"
    when "used-pd" then "#used-pd #{e}"
    when "used-pw" then "#used-pw #{e}"
    else ""

get_row = (n) ->
  sel = row_sel n
  _.map [ $(sel).first().val(), $(sel).last().val() ], (s) -> parseInt(s)

set_row = (n, vals, ideals) ->
  $(row_sel n).first().val if isNaN(vals[0]) then "" else round_to(vals[0], 1)
  $(row_sel n).last().val if isNaN(vals[1]) then "" else round_to(vals[1], 2)

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
    m = m_val != "" and m_val != default_input_txt and
      (isNaN(m_val) or m_val < 0 or m_val > plan[0])
    p = p_val != "" and p_val != default_input_txt and
      (isNaN(p_val) or p_val < 0 or p_val > plan[1])
    (if m or p
      $(row).find("td.extra span.error").show()
    else
      $(row).find("td.extra span.error").hide()
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


$(document).ready ->

  # insert the plan options into the table.
  # we reverse the plans so they get inserted in the right order.
  plans.reverse()
  # insert each plan.
  _.each plans, (p, i) ->
    row = $("<tr class='choices highlight' id='plan#{plans.length-i-1}'></tr>").prependTo "table#plans tbody"
    _.each [
      $("<td class='results title'>Total</td>"),
      $("<td>#{p[0]}</td>").addClass("m"),
      $("<td>#{p[1]}</td>").addClass("p")
    ], (cell) ->
      cell.appendTo row
  # reverse the plans back so we don't cause any unexpecetd behavior.
  plans.reverse()

  # display some preliminary info.
  $("#date").text (new Date).toDateString()
  $("#days-left").text d_left

  # we'll work on allowing input for the secondary elements later.
  $(".secondary input").attr("disabled", true)

  $("tr.choices td").click ->
    $row = $(this).parent("tr")
    row = $row.get(0)
    if $row.hasClass "highlight"
      $("tr.choices.highlight").removeClass "highlight"
      $row.addClass "totalRow"
      plan = plans[row.id.split("plan")[1]]

      # hide all the other rows
      $("tr.choices").filter( -> this != row).hide()

      # show various stuff
      $(".results").show()
      $row.append back_cell

      ideal_left = _.map(plan, (n) -> n * d_left / d_total)
      ideal_used = _.map(plan, (n) -> n * d_so_far / d_total)
      ideal_pd = _.map(plan, (n) -> n / d_total)
      ideal_pw = _.map(plan, (n) -> n / w_total)

       # fill in the ideal information
      _.each ["left", "left-pd", "left-pw", "used", "used-pd", "used-pw"], (n) ->
        _.each ["m", "p"], (x) ->
          ideals = switch n
            when "left" then ideal_left
            when "used" then ideal_used
            when "left-pd", "used-pd" then ideal_pd
            when "left-pw", "used-pw" then ideal_pw
          pos = switch x
            when "m" then 0
            when "p" then 1
          round = switch x
            when "m" then 1
            when "p" then 2
          $(row_sel n, "ideal-#{x}").text round_to(ideals[pos], round)


  $("#back").click ->
    back_cell.detach()
    $("tr.choices").removeClass("totalRow").addClass("highlight")
    $(".results").hide()
    $("tr.choices").show()
    $(row_sel "left").val(default_input_txt)
    $(".primary input").keyup()
    $("#plans td.error").text("")

  back_cell = $("#back-cell").detach()

  $(".primary input").val default_input_txt

  $(".primary input").keyup ->
    validate()
    populate_with_left plan

  $(".primary input").focus ->
    $(this).val("") if $(this).val() == default_input_txt

  $(".primary input").click ->
    this.select()

  $(".primary input").blur ->
    $(this).val(default_input_txt) if $(this).val() == ""
