$.fn.hasAnyClass = ->
  array = arguments[0]
  i = 0
  while i < array.length
    if @hasClass(array[i])
      return true
    i++
  false