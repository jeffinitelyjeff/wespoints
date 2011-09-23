get_d_left = (today) ->
  return 10 # FIXME: perform calculation!

get_w_left = (today) ->
  return 2 # FIXME!

cell = (row, n) ->
  $(row + " td:nth-child(#{n+2}) input")


populate_with_left = (days, weeks, plan) ->
  left = [ parseInt(cell("#left", 0).val()), parseInt(cell("#left", 1).val()) ]

  console.log left

  left_pd = _.map left, (n) -> n / days
  $("#left-pd td:nth-child(2) input").val left_pd[0]
  $("#left-pd td:nth-child(3) input").val left_pd[1]

  left_pw = _.map left, (n) -> n / weeks
  $("#left-pw td:nth-child(2) input").val left_pw[0]
  $("#left-pw td:nth-child(3) input").val left_pw[1]

  used = [ plan[0] - left[0], plan[1] - left[1] ]
  $("#used td:nth-child(2) input")
  console.log used
  console.log used



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


