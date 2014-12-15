require "css/base.less"
Denature = require "denature"
THREE = require "three"

Board = require "./board"
Lights = require "./lights"


class Tactics extends Denature.App
  @origin = new THREE.Vector3(0, 0, 0)

  initialize: (el, options) ->
    @camera.position.set(800, 500, 800)
    @camera.lookAt(Tactics.origin)

    @board = new Board
    @light = new THREE.PointLight(0xFFFFFF)
    @light.position.set(0, 500, 0)

    @insert @board
    @scene.add @light
    @subscribe "scroll", @rotate

  rotate: (e) ->
    dtheta = e.scrollDelta().x * 0.004
    pos = @camera.position
    radius = Math.sqrt(pos.x * pos.x + pos.z * pos.z)
    theta = Math.atan2(pos.z, pos.x) + dtheta
    pos.setX(Math.cos(theta) * radius)
    pos.setZ(Math.sin(theta) * radius)
    @camera.lookAt(Tactics.origin)


module.exports = self.Tactics = Tactics
