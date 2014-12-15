Denature = require "denature"
THREE = require "three"


class Tile extends Denature.Model
  @size: 50
  @height: 5
  @gap: 0

  initialize: (options) ->
    @row = options.row
    @col = options.col
    @geo = new THREE.Mesh(
      new THREE.CylinderGeometry(Tile.size, Tile.size, Tile.height, 6),
      new THREE.MeshPhongMaterial(
        color: 0xCCCCCC
        ambient: 0xCCCCCC
        specular: 0xAAAAAA
        shininess: 100
      )
    )

    step = 2 * Tile.size + Tile.gap
    @geo.position.set(@row * step, 0, @col * step)
    @include @geo
    @subscribe "ready", @attachEvents

  attachEvents: ->
    @subscribe @root, "timer", @timer

  timer: (payload) ->
    @geo.rotation.y += 0.004


module.exports = Tile
