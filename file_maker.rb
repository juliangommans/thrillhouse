########## vv REAL CODE vv ##############
class BBMbuilder

  def initialize(options)#title, appname, branchname, routable, custom="")
    @branchname = options[:branchname]
    @appname = options[:appname]
    @routable = options[:routable]
    @title = options[:title]
    @capitolname = @appname.capitalize
    @capbranch = @branchname.capitalize
    @base_route = "app/assets/javascripts#{options[:custom]}"
    @base_app_route = "#{@base_route}/apps"
    @app_route = "#{@base_app_route}/#{@appname}"
    @app_module = "#{@app_route}/#{@branchname}"
    @templates = "#{@app_module}/templates"
  end

  def initial_setup
    self.build_setup_routes
    self.build_setup_files
  end

  def build_setup_routes
    @config = "#{@base_route}/config"
    @marionette = "#{@config}/marionette"
    @backbone = "#{@config}/backbone"
    @entities = "#{@base_route}/entities"
    @entities_base = "#{@entities}/_base"
    views = "#{@base_route}/views"
    @views_base = "#{views}/_base"
    @controllers = "#{@base_route}/controllers"
    routes = [@base_route, @config, @marionette, @backbone, @entities, @entities_base, views, @views_base, @controllers]
    routes.each do |route|
      Dir.mkdir(route) unless File.exists?(route)
    end
  end

  def build_setup_files
    self.app_base_setup
    self.app_config
    self.app_base_entities
    self.app_views
    self.app_controllers
  end

  def app_base_setup
    File.open("#{@base_route}/app.js.coffee", "w+") { |f| f.write(self.app_js) } unless File.file?("#{@base_route}/app.js.coffee")
  end

  def app_config
    File.open("#{@config}/javascript.js.coffee", "w+") { |f| f.write(self.config_js) } unless File.file?("#{@config}/javascript.js.coffee")
    File.open("#{@backbone}/sync.js.coffee", "w+") { |f| f.write(self.sync_js) } unless File.file?("#{@backbone}/sync.js.coffee")
    ["application", "renderer"].each do |app|
      File.open("#{@marionette}/#{app}.js.coffee", "w+") { |f| f.write(self.send("marionette_#{app}")) } unless File.file?("#{@marionette}/#{app}")
    end
  end

  def app_base_entities
    File.open("#{@entities}/_fetch.js.coffee", "w+") { |f| f.write(self.fetch_js)} unless File.file?("#{@entities}/_fetch.js.coffee")
    ["collections","models"].each do |file|
      File.open("#{@entities_base}/#{file}.js.coffee", "w+") {|f| f.write(self.send("entities_#{file}")) } unless File.file?("{@entities_base}/#{file}.js.coffee")
    end
  end

  def app_views
   ["collectionview","compositeview", "itemview", "layout", "view"].each do |file|
      File.open("#{@views_base}/#{file}.js.coffee", "w+") {|f| f.write(self.send("views_#{file}")) } unless File.file?("{@views_base}/#{file}.js.coffee")
    end
  end

  def app_controllers
    File.open("#{@controllers}/_base.js.coffee", "w+") { |f| f.write(self.controllers_base) } unless File.file?("#{@controllers}/_base.js.coffee")
  end

  def rails_setup
    File.open("app/assets/javascripts/application.js", "w+") { |f| f.write(self.application_js_coffee) }
    # File.open("config/initializers/handle_bars.rb", "w+") { |f| f.write(self.handle_bars_init)}
    # File.open("config/application.rb", "w+") { |f| f.write(self.config_application)}
    File.open("config/routes.rb", "w+") { |f| f.write(self.root_route) }
    Dir.mkdir("app/views/application")
    File.open("app/views/application/index.html.erb", "w+") { |f| f.write(self.application_view) }
    File.open("app/controllers/application_controller.rb", "w+") { |f| f.write(self.application_controller) }
    File.open("Gemfile", "w+") { |f| f.write(self.gem_file) }
  end

  def root_route
    "#{@title}::Application.routes.draw do

  root to: 'application#index'

end"
  end

  def application_view
    "<div id='header-region'></div>
<div id='main-region'></div>
<div id='footer-region'></div>

<%= javascript_tag do %>
  $(function() {
    #{@title}.start({
      environment: '<%= Rails.env %>'
    });
  });
<% end %>"
  end

  def application_controller
    "class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index

  end
end"
  end

  def app_js
    "@#{@title} = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on 'before:start', (options) ->
    App.environment = options.environment

  App.addRegions
    headerRegion: '#header-region'
    mainRegion: '#main-region'
    footerRegion: '#footer-region'

  App.rootRoute = Routes.root_path()

  App.addInitializer ->
    # App.module('HeaderApp').start()
    # App.module('FooterApp').start()

  App.reqres.setHandler 'default:region', ->
    App.mainRegion

  App.commands.setHandler 'register:instance', (instance, id) ->
    App.register instance, id if App.environment is 'development'

  App.commands.setHandler 'unregister:instance', (instance, id) ->
    App.unregister instance, id if App.environment is 'development'

  App.on 'start', ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()

  App"
  end

  def config_js
    "Array::insertAt = (index, item) ->
  @splice(index, 0, item)
  @"
  end

  def sync_js
    "do (Backbone) ->
  _sync = Backbone.sync

  Backbone.sync = (method, entity, options = {}) ->

    _.defaults options,
      beforeSend: _.bind(methods.beforeSend, entity)
      complete: _.bind(methods.complete, entity)

    sync = _sync(method, entity, options)
    if !entity._fetch and method is 'read'
      entity._fetch = sync

  methods =
    beforeSend: ->
      @trigger 'sync:start', @

    complete: ->
      @trigger 'sync:stop', @"
  end

  def fetch_js
    "@#{@title}.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  App.commands.setHandler 'when:fetched', (entities,callback) ->

    xhrs = _.chain([entities]).flatten().pluck('_fetch').value()

    $.when(xhrs...).done ->
      callback()"
  end

  def marionette_application
    "do (Backbone) ->

  _.extend Backbone.Marionette.Application::,

    navigate: (route, options = {}) ->
      # route = '#' + route if route.charAt(0) is '/'
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    startHistory: ->
      if Backbone.history
        Backbone.history.start()

    register: (instance, id) ->
      @_registry ?= {}
      @_registry[id] = instance

    unregister: (instance, id) ->
      delete @_registry[id]

    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of @_registry
        controller.region.close()
      msg = \"There were \#{oldCount} controllers in the registry, there are now \#{@getRegistrySize()}\"
      if @getRegistrySize() > 0 then console.warn(msg, @_registry) else console.log(msg)

    getRegistrySize: ->
      _.size @_registry"
  end

  def marionette_renderer
    "do (Marionette) ->
  _.extend Marionette.Renderer,

    lookups: ['#{@appname}/apps/']

    render: (template, data) ->
      path = @getTemplate(template)
      throw \"Template \#{template} not found!\" unless path
      path(data)

    getTemplate: (template) ->
      for path in [template, template.split('/').insertAt(-1, 'templates').join('/')]
        for lookup in @lookups
          return JST[lookup + path] if JST[lookup + path]"
  end

  def entities_collections
    "@#{@title}.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Collection extends Backbone.Collection"
  end

  def entities_models
    "@#{@title}.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Model extends Backbone.Model
    destroy: (options = {}) ->
      _.defaults options,
        wait: true

      @set _destroy: true
      super options

    isDestroyed: ->
      @get '_destroy'

    save: (data, options = {}) ->
      isNew = @isNew()

      _.defaults options,
        wait: true
        success: _.bind(@saveSuccess, @, isNew, options.collection)
        error: _.bind(@saveError, @)

      @unset '_errors'
      super data, options

    saveSuccess: (isNew, collection) ->
      if isNew
        collection.add @ if collection
        collection.trigger 'model:created', @ if collection
        @trigger 'created', @
      else
        collection ?= @collection
        collection.trigger 'model:updated', @ if collection
        @trigger 'updated', @

    saveError: (model, xhr, options) ->
      @set _errors: $.parseJSON(xhr.responseText)?.errors unless xhr.status is 500 or xhr.status is 404"
  end

  def views_collectionview
    "@#{@title}.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  class Views.CollectionView extends Marionette.CollectionView"
  end

  def views_compositeview
    "@#{@title}.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  class Views.CompositeView extends Marionette.CompositeView"
  end

  def views_itemview
    "@#{@title}.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  class Views.ItemView extends Marionette.ItemView"
  end

  def views_layout
    "@#{@title}.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  class Views.Layout extends Marionette.Layout"
  end

  def views_view
    "@#{@title}.module 'Views', (Views, App, Backbone, Marionette, $, _) ->

  _remove = Marionette.View::remove

  _.extend Marionette.View::,

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    remove: (args...) ->
      console.log 'removing', @
      _remove.apply @, args

    templateHelpers: ->

      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false

        url = '#' + url unless options.external

        \"<a href=\"\#{url}\">\#{@escape(name)}</a>\""
  end

  def controllers_base
    "@#{@title}.module 'Controllers', (Controllers, App, Backbone, Marionette, $, _) ->

  class Controllers.Base extends Marionette.Controller

    constructor: (options = {}) ->
      @region = options.region or App.request 'default:region'
      super options
      @_instance_id = _.uniqueId('controllers')
      App.execute 'register:instance', @, @_instance_id

    destroy: (args...) ->
      delete @region
      delete @options
      super args
      App.execute 'unregister:instance', @, @_instance_id

    show: (view) ->
      @listenTo view, 'destroy', @destroy
      @region.show view"
  end

  def gem_file
    "source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.13'
gem 'thin'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'
gem 'bootstrap-sass'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem 'compass-rails'
gem 'js-routes'
gem 'rabl'
gem 'eco'
gem 'oj'
gem 'gon'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
"
  end

  def application_js_coffee
    "//= require jquery
//= require jquery_ujs
//= require lib/underscore
//= require lib/backbone
//= require lib/marionette
//= require js-routes
//= require turbolinks
//= require_tree ./#{@appname}/config
//= require #{@appname}/app
//= require_tree ./#{@appname}/controllers
//= require_tree ./#{@appname}/views
//= require_tree ./#{@appname}/entities
//= require_tree ./#{@appname}/apps
//= require bootstrap-sprockets
//= require_tree ."
  end

#   def config_application
#     "require File.expand_path('../boot', __FILE__)

# require 'rails/all'

# # Require the gems listed in Gemfile, including any gems
# # you've limited to :test, :development, or :production.
# Bundler.require(*Rails.groups)

# module #{@title}
#   class Application < Rails::Application

#     config.assets.initialize_on_precompile = true

#     config.assets.precompile += [
#       'application.js'
#     ]
#   end
# end"
#   end

#   def handle_bars_init
#     "##
# # Handlebars Configuration
# ::HandlebarsAssets.configure do |config|
#   config.path_prefix = 'javascripts'
# end
# "
#   end


####### vv -- Post Setup app builder -- vv ##########

  def constructor
    self.build_routes
    self.build_files
    self.build_templates
  end

  def build_routes
    [@base_route, @base_app_route, @app_route, @app_module, @templates].each do |route|
      Dir.mkdir(route) unless File.exists?(route)
    end
  end

  def build_files
    files = Hash.new
    if @routable
      files["router"] = "#{@app_route}/#{@appname}_app.js.coffee"
      create_entities
    else
      files["base"] = "#{@app_route}/#{@appname}_app.js.coffee"
    end
    files["controller"] = "#{@app_module}/#{@branchname}_controller.js.coffee"
    files["view"] = "#{@app_module}/#{@branchname}_view.js.coffee"

    files.each do |k,v|
      File.open(v, "w+") { |f| f.write( self.send("app_#{k}")) } unless File.file?(v)
    end
  end

  def build_templates
    extension = '.jst.eco'
    ["_#{@branchname}","#{@branchname}_layout", "_#{@appname}"].each do |temp|
      File.open( @templates + '/' + temp + extension, 'w') unless File.file?(@templates + '/' + temp + extension)
    end
  end

  def app_base
    "@#{@title}.module '#{@capitolname}App', (#{@capitolname}App, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    #{@branchname}: ->
      new #{@capitolname}App.#{@capbranch}.Controller
        region: App.#{@appname}Region

  #{@capitolname}App.on 'start', ->
    API.#{@branchname}()"
  end

  def app_router
    "@#{@title}.module '#{@capitolname}App', (#{@capitolname}App, App, Backbone, Marionette, $, _) ->

  class #{@capitolname}App.Router extends Marionette.AppRouter
    appRoutes:
      '#{@appname}' : '#{@branchname}'

  API =
    #{@branchname}: ->
      new #{@capitolname}App.#{@capbranch}.Controller

  App.reqres.setHandler '#{@appname}:#{@branchname}', ->
    App.navigate Routes.#{@appname}_path()
    API.#{@branchname}()

  App.addInitializer ->
    new #{@capitolname}App.Router
      controller: API"
  end

  def app_controller
    "@#{@title}.module '#{@capitolname}App.#{@capbranch}', (#{@capbranch}, App, Backbone, Marionette, $, _) ->

  class #{@capbranch}.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayout()
      @listenTo @layout, 'show', =>
        @#{@branchname}View()
      @show @layout

    getLayout: ->
      new #{@capbranch}.Layout

    #{@branchname}View: ->
      #{@branchname}View = @get#{@capbranch}View()
      @layout.#{@branchname}Region.show #{@branchname}View

    get#{@capbranch}View: ->
      new #{@capbranch}.#{@capitolname}"
  end

  def app_view
    "@#{@title}.module '#{@capitolname}App.#{@capbranch}', (#{@capbranch}, App, Backbone, Marionette, $, _) ->

  class #{@capbranch}.#{@capitolname} extends App.Views.ItemView
    template: '#{@appname}/#{@branchname}/_#{@appname}'

  class #{@capbranch}.#{@capbranch} extends App.Views.ItemView
    template: '#{@appname}/#{@branchname}/_#{@branchname}'

  class #{@capbranch}.Layout extends App.Views.Layout
    template: '#{@appname}/#{@branchname}/#{@branchname}_layout'
    regions:
      #{@branchname}Region: '\##{@branchname}-region'"
  end

  def create_entities
    File.open("#{@base_route}/entities/#{@appname}.js.coffee", "w+") { |f| f.write(self.app_entities) } unless File.file?("#{@base_route}/entities/#{@appname}.js.coffee")
  end

  def app_entities
    "@#{@title}.module 'Entities', (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.#{@capitolname} extends App.Entities.Model
    urlRoot: -> Routes.#{@appname}_index_path()

  class Entities.#{@capitolname}Collection extends App.Entities.Collection
    model: Entities.#{@capitolname}
    url: -> Routes.#{@appname}_index_path()

  API =
    get#{@capitolname}s: ->
      #{@appname}s = new Entities.#{@capitolname}Collection
      #{@appname}s.fetch
        reset: true
      #{@appname}s
    get#{@capitolname}: (id) ->
      #{@appname} = new Entities.#{@capitolname}
        id: id
      #{@appname}.fetch()
      #{@appname}
    new#{@capitolname}: ->
      new Entities.#{@capitolname}

  App.reqres.setHandler '#{@appname}:entities', ->
    API.get#{@capitolname}s()

  App.reqres.setHandler '#{@appname}:entity', (id) ->
    API.get#{@capitolname} id

  App.reqres.setHandler 'new:#{@appname}:entity', ->
    API.new#{@capitolname}()"
  end


end
########## ^^ REAL CODE ^^ ##############

options = {
  title: "Thrillhouse",
  appname: "lilcric",
  branchname: "show",
  routable: true,
  custom: "/thrillhouse"
}

x = BBMbuilder.new(options)#"PlanetExpress", "#{@appname}", "edit", false, "backbone/apps/")
# x.rails_setup
# x.initial_setup
x.constructor
