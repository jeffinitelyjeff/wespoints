default_input_txt = "--"

# This is the only thing that should need updating between semesters.
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

$(document).ready ->

  $("#date").text (new Date).toDateString()
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
    $(row_sel "left").val(default_input_txt)

  $("#go").click -> # replace this with any change in the primary fields
    populate_with_left plan

  $(".primary input").focus ->
    $(this).val("") if $(this).val() == default_input_txt

  $(".primary input").blur ->
    $(this).val(default_input_txt) if $(this).val() == ""

