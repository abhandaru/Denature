###
Base application class.
@copyright 2013
@author Adu Bhandaru
###

Camera = require "../models/camera"
Renderer = require "../models/renderer"
Scene = require "../models/scene"
util = require "../util/util"


class App
  ###
  A static member hash of default options to merge into any options the client
  may pass in. These are the base traits with the least priority.
  ###
  @defaults:
    animate: true
    bindResize: true


  ###
  An options hash for an extending class to override (cannot be partially
  overriden). The client can omit defining theses to use the defualts.
  ###
  options: util.extend { }, App.defaults


  ###
  Called before the object is constructed.
  Logic sets up the camera, scene, renderer, and events.
  @param {HTMLElement} A container for your application.
  @param {Object} options An override hash for the default options.
  ###
  constructor: (@el, options) ->
    params = util.extend({ }, App.defaults, @options, options)
    @width = @el.offsetWidth
    @height = @el.offsetHeight

    # set up rendering environement
    @camera = Camera.create aspect: @width / @height
    @scene = Scene.create(@camera)
    @renderer = Renderer.create(@width, @height)
    @canvas = @renderer.domElement

    # bind element and append canvas
    @el.appendChild @canvas

    # call client code
    @init(@el, options)

    # automatically resize canvas
    if params.bindResize
      self.addEventListener('resize', @resize.bind @, false)

    # start up render loop
    if params.animate
      Renderer.loop(@render.bind @)


  ###
  Custom init method.
  This should be overriden in the subclass.
  @param {HTMLElement} el A container for your application.
  @param {Object} options An override hash for the default options.
  ###
  init: (el, options) ->


  ###
  Called when the window is resized to fit the bounds.
  ###
  resize: () ->
    @width = @el.offsetWidth
    @height = @el.offsetHeight
    @renderer.setSize(@width, @height)
    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()


  ###
  This gets called by the render loop.
  @return {void}
  ###
  render: (dt) ->
    @update(dt);
    @renderer.render(@scene, @camera)


  ###
  Call any logic that would change your game state every timestep.
  For example, animations may require you to update an object's position.
  @return {void}
  ###
  update: (dt) ->


module.exports = App
