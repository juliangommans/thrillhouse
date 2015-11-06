$.fn.hasAnyClass = ->
  array = arguments[0]
  i = 0
  while i < array.length
    if @hasClass(array[i])
      return true
    i++
  false

# $.fn.rotate = (degrees) ->
#   $(this).css
#     '-webkit-transform': 'rotate(' + degrees + 'deg)'
#     '-moz-transform': 'rotate(' + degrees + 'deg)'
#     '-ms-transform': 'rotate(' + degrees + 'deg)'
#     'transform': 'rotate(' + degrees + 'deg)'
#   return
