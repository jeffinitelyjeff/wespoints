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
  start: "Sep 3, 2011"
  end: "Dec 18, 2011"
  breaks: [
    # Fall break
    [ "Oct 21, 2011", "Oct 26, 2011" ],
    # Thanksgiving break
    [ "Nov 22, 2011", "Nov 28, 2011" ]
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

  # display ideal info on hover only if there aren't any errors

  m_err = $(".primary .error-m")
  p_err = $(".primary .error-p")
  m_p_err = $(".primary .error-m-p")

  # display ideal meals
  # if _.all(m_p_err, (e) -> $(e).is(":hidden")) and _.all(m_err, (e) ->
  # $(e).is(":hidden"))
  if valid_meals()
    $("tr.secondary td.m").hover(
      () -> $(this).parent().find(".ideal-m").show(),
      () -> $(this).parent().find(".ideal-m").hide()
    )
  else
    $("tr.secondary td.m").unbind "mouseenter mouseleave"
    $(".ideal-m").hide()

  # display ideal points
  # if _.all(m_p_err, (e) -> $(e).is(":hidden")) and _.all(p_err, (e) ->
  # $(e).is(":hidden"))
  if valid_points()
    $("tr.secondary td.p").hover(
      () -> $(this).parent().find(".ideal-p").show(),
      () -> $(this).parent().find(".ideal-p").hide()
    )
  else
    $("tr.secondary td.p").unbind "mouseenter mouseleave"
    $(".ideal-p").hide()

# Notice that this differs form the validity checking in `generate_errors`
# because we don't generate errors for "" or default_input_txt, but we
# don't consider them valid either.
valid_meals = ->
  _.all $("tr.primary"), (row) ->
    val = $(row).find("td.m input").val()
    !isNaN(val) and parseInt(val) > 0 and parseInt(val) < plan[0]

# Notice that this differs form the validity checking in `generate_errors`
# because we don't generate errors for "" or default_input_txt, but we
# don't consider them valid either.
valid_points = ->
  _.all $("tr.primary"), (row) ->
    val = $(row).find("td.p input").val()
    !isNaN(val) and parseInt(val) > 0 and parseInt(val) < plan[1]


generate_errors = ->
  _.each $("tr.primary"), (row) ->
    m_val = $(row).find("td.m input").val()
    p_val = $(row).find("td.p input").val()
    m = m_val != "" and m_val != default_input_txt and
      (isNaN(m_val) or parseInt(m_val) < 0 or parseInt(m_val) > plan[0])
    p = p_val != "" and p_val != default_input_txt and
      (isNaN(p_val) or parseInt(p_val) < 0 or parseInt(p_val) > plan[1])

    if m and p
      show = ".error-m-p"
      hide = [".error-m", ".error-p"]
    else if m
      show = ".error-m"
      hide = [".error-m-p", ".error-p"]
    else if p
      show = ".error-p"
      hide = [".error-m-p", ".error-m"]
    else
      show = ""
      hide = [".error-m", ".error-p", ".error-m-p"]

    $(row).find(show).show()
    $(row).find(hide.join ", ").hide()

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
    $("#help-text").hide()
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
          $("##{n} .ideal-#{x} .ideal-num").text round_to(ideals[pos], round)


  $("#back").click ->
    $("#help-text").show()
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
    generate_errors()
    populate_with_left plan

  $(".primary input").focus ->
    $(this).val("") if $(this).val() == default_input_txt

  $(".primary input").click ->
    this.select()

  $(".primary input").blur ->
    $(this).val(default_input_txt) if $(this).val() == ""
