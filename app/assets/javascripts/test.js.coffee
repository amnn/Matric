# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

topics_setup = ->
	update_topics_field()
	$(".topic").click ->
		$(this).toggleClass "on"
		update_topics_field()


update_topics_field = ->
	field = ""
	$(".topic.on").each (i) ->
		field += $(this).text()
		field += " "
	$("#test-topics").val field
	
test_type_setup = ->
	update_test_type_field()
	$(".test-type").click ->
		$(".test-type").removeClass "on"
		$(this).addClass "on"
		update_test_type_field()

update_test_type_field = ->
	field = $(".test-type.on:first").text()
	$("#test-type").val field


$(document).ready topics_setup
$(document).ready test_type_setup