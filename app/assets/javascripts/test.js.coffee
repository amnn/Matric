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


options_setup = ->
	$("#option-area ul li").click ->
		if $("#option-area ul li.correct, #option-area ul li.incorrect").size() == 0
			check_answer this

check_answer = (elem) ->
	real_digest = hex_md5 $(elem).html()
	test_digest = $("#test_digest").val()
	
	$("#option-area ul li").each (i) ->
		digest = hex_md5 $(this).html()
		
		if test_digest is digest
			$(this).removeClass().addClass "correct"
			unless digest is real_digest
				$(elem).removeClass().addClass "incorrect"
			
		
		
$(document).ready topics_setup
$(document).ready test_type_setup
$(document).ready options_setup