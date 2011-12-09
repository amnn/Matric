init_accordians = ->
  $('ul.accordian ul').hide()

  $.each $('ul.accordian'), ->
    $('#' + this.id + '.startOpen ul:first').show()

  $('ul.accordian a').click ->
    neighbour = $(this).next()
    parent    = this.parentNode.parentNode.id

    if neighbour.is 'ul:hidden'
      $('#' + parent + ' ul:visible').slideUp 'normal'
      neighbour.slideDown 'normal'
    else if neighbour.is 'ul:visible'
      $('#' + parent + ' ul:visible').slideUp 'normal'

$(document).ready init_accordians