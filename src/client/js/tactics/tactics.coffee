require "css/base.less"
Denature = require "denature"
THREE = require "three"

HexagonGeometry = require "./geometries/hexagon-geometry"


class Tactics extends Denature.App
  initialize: (el, options) ->
    @camera.position.set(500, 500, 500)
    @camera.lookAt(new THREE.Vector3(0, 0, 0))
    @insert new Model

class Model extends Denature.Model
  initialize: (options) ->
    @geo = new THREE.Mesh(
      new HexagonGeometry(200, 1),
      new THREE.MeshNormalMaterial())
    @include @geo
    @subscribe "ready", @attachEvents

  attachEvents: ->
    @subscribe @root, "timer", @timer

  timer: (payload) ->
    @geo.rotation.y += 0.02


module.exports = self.Tactics = Tactics
