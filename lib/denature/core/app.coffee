THREE = require "three"

Camera = require "../factories/camera"
Monitor = require "../events/monitor"
Node = require "./node"
Renderer = require "../factories/renderer"
Scene = require "../factories/scene"
util = require "../util/util"


class App extends Node
  ###
  A static member hash of default options to merge into any options the client
  may pass in. These are the base traits with the least priority.
  ###
  @defaults:
    animate: true
    bindResize: true
    interactive: true


  ###
  An options hash for an extending class to override (cannot be partially
  overriden). The client can omit defining theses to use the defualts.
  ###
  options: util.extend { }, App.defaults


  ###
  Called while the object is constructed.
  Logic sets up the camera, scene, renderer, and events.
  @param {HTMLElement} A container for your application.
  @param {Object} options An override hash for the default options.
  ###
  constructor: (@el, options) ->
    super()

    @options = util.extend({ }, App.defaults, @options, options)
    @width = @el.offsetWidth
    @height = @el.offsetHeight

    # set up rendering environement
    @camera = Camera.create aspect: @width / @height
    @scene = Scene.create(@camera)
    @renderer = Renderer.create(@width, @height)
    @canvas = @renderer.domElement
    @el.appendChild @canvas
    @root = @

    # hook up scene interaction
    if @options.interactive
      @__denature__monitor = new Monitor(@, @el)

    # automatically resize canvas
    if @options.bindResize
      self.addEventListener 'resize', (=> @trigger 'resize'), false
      @subscribe 'resize', @__denature__resize

    # start up render loop
    if @options.animate
      Renderer.loop(@__denature__timer.bind @)

    # invoke client code
    @initialize @el, @options


  ###
  Custom init method.
  This should be overriden in the subclass.
  @param {HTMLElement} el A container for your application.
  @param {Object} options A hash of _fully_ resolved options.
  ###
  initialize: (el, options) ->


  ###
  Insert a model into this subtree. This determines object hierarchy in the
  scene, and how events bubble up the tree.
  @param {Model} model The model to insert.
  ###
  insert: (model) ->
    super(model)
    @scene.add(model.__denature__object)
    model.__denature__setRoot @
    @


  remove: (model) ->
    super(model)
    @scene.remove model.__denature__object
    @__denature__forget model


  ###
  Called when the window is resized to fit the bounds.
  ###
  __denature__resize: () ->
    @width = @el.offsetWidth
    @height = @el.offsetHeight
    @renderer.setSize(@width, @height)
    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()


  ###
  This gets called by the render loop.
  ###
  __denature__timer: (dt) ->
    @trigger('timer', dt: dt)
    @renderer.render(@scene, @camera)


  ###
  Remove event bindings and event monitor tracking for model and all children.
  ###
  __denature__forget: (model) ->
    model.__denature__monitor?.forget @
    for child in model.__denature__children
      @__denature__forget(child)


module.exports = App
