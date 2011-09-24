get_d_left = (today) ->
  return 10 # FIXME: perform calculation!

get_w_left = (today) ->
  return 2 # FIXME!

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
  $(sel).first().val vals[0]
  $(sel).last().val vals[1]

populate_with_left = (days, weeks, plan) ->
  left = get_row "left"
  set_row "left-pd", _.map(left, (n) -> n / days)
  set_row "left-pw", _.map(left, (n) -> n / weeks)

  used = [ plan[0] - left[0], plan[1] - left[1] ]
  set_row "used", used
  set_row "used-pd", _.map(used, (n) -> n / days)
  set_row "used-pw", _.map(used, (n) -> n / weeks)

$(document).ready ->
  d = new Date
  $("#date").text d.toDateString()
  d_left = get_d_left d
  w_left = get_w_left d
  $("#days-left").text d_left

  plan = []

  rows = $("#plans > tbody > tr")
  rows.click ->
    # empty out the plan array before putting new values in it
    plan.pop() for i in [0..plan.length]
    # put new plan values in
    $(this).children("td").each ->
      plan.push parseInt $(this).text()

    # hide all the other rows
    that = this
    rows.filter( -> this != that).hide()

    # show various stuff
    $("#results").show()
    $("#back").show()
    $("#go").show()

  $("#back").click ->
    $("#results").hide()
    rows.show()

  $("#go").click -> # replace this with any change in the primary fields
    populate_with_left d_left, w_left, plan


