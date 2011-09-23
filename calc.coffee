$(document).ready ->
  rows = $("#plans > tbody > tr")
  rows.click ->
    row = this
    rows.filter( -> this != row).hide ->
      $("fieldset").show()

  $("#back").click ->
    rows.show()
    $("fieldset").hide()

  $("#go").click ->
    $("#results").show()
    # FIXME: PERFORM CALCULATIONS!
