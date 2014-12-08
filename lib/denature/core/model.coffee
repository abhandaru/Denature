Node = require "../core/node"
THREE = require "three"
util = require "../util/util"


class Model extends Node
  ###
  A static member hash of default options to merge into any options the client
  may pass in. These are the base traits with the least priority.
  ###
  @defaults:
    interactive: true


  ###
  An options hash for an extending class to override (cannot be partially
  overriden). The client can omit defining theses to use the defualts.
  ###
  options: util.extend { }, Model.defaults


  ###
  Called while the object is constructed.
  @param {Object} options An override hash for the default options.
  ###
  constructor: (options) ->
    super()

    # Resolve options
    @options = util.extend { }, Model.defaults, @options, options

    # Create skeleton view
    @__denature__includes = [ ]
    @__denature__object = new THREE.Object3D

    # Invoke client code
    @initialize @options


  ###
  Custom init method.
  This should be overriden in the subclass.
  @param {Object} options A hash of _fully_ resolved options.
  ###
  initialize: (options) ->


  ###
  Add a THREE object to the model definition.
  @param {THREE.Object3D} object The object to insert.
  ###
  include: (object) ->
    @__denature__includes.push object
    @__denature__object.add(object)
    @__denature__updateTracking()


  ###
  Insert a model into this subtree. This determines object hierarchy in the
  scene, and how events bubble up the tree.
  @param {Model} model The model to insert.
  ###
  insert: (model) ->
    super(model)
    @__denature__object.add(model.__denature__object)
    @__denature__updateTracking()
    @trigger "ready" if model.root?


  ###
  Remove any event listeners installed by the given model, objects inserted
  into the scene and event monitor, and then cascade this action down to the
  children.
  ###
  remove: (model) ->
    super(model)
    @__denature__object.remove model.__denature__object
    @__denature__forget model


  ###
  Set the root of this subtree to the one provided.
  @param {App} root The root of the event tree.
  ###
  __denature__setRoot: (root) ->
    @root = root
    @__denature__monitor = root.__denature__monitor
    if @options.interactive
      @__denature__monitor.track @

    # Indicate that the model is ready for bindings
    @trigger "ready"
    for child in @__denature__children
      child.__denature__setRoot(root)


  ###
  Tell the event monitor that this module needs to update the tracking for
  its objects in the scene.
  ###
  __denature__updateTracking: () ->
    return @ unless @__denature__monitor? and @options.interactive
    @__denature__monitor.update @
    console.log @__denature__monitor


  ###
  Remove event bindings and event monitor tracking for model and all children.
  ###
  __denature__forget: (model) ->
    model.__denature__monitor?.forget @
    for child in model.__denature__children
      @__denature__forget(child)


module.exports = Model
