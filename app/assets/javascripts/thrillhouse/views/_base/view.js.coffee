@Thrillhouse.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  _remove = Marionette.View::remove

  _.extend Marionette.View::,

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    remove: (args...) ->
      # console.log 'removing', @
      _remove.apply @, args

    templateHelpers: ->

      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false

        url = '#' + url unless options.external

        "<a href="#{url}">#{@escape(name)}</a>"

    showData: (args) ->
      $(args.currentTarget).popover('show')
    hideData: (args) ->
      $(args.currentTarget).popover('hide')

    returnFalse: ->
      return false

    selected: (args, classname) ->
      classname or= 'selected'
      if $(args.currentTarget).hasClass(classname)
        $(args.currentTarget).removeClass(classname)
      else
        $(".#{classname}").removeClass(classname)
        $(args.currentTarget).addClass(classname)

    closeBackdrop: ->
      $('.modal-backdrop').remove();

