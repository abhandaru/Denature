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
    options = util.extend { }, Model.defaults, @options, options

    # Create skeleton view
    @__denature_object = new THREE.Object3D

    # Invoke client code
    @initialize options


  ###
  Custom init method.
  This should be overriden in the subclass.
  @param {Object} options A hash of _fully_ resolved options.
  ###
  initialize: (options) ->


module.exports = Model
