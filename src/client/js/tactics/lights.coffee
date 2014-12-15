Denature = require "denature"
THREE = require "three"


class Lights extends Denature.Model

  initialize: (options) ->
    @light = new THREE.PointLight(0xFFFFFF)
    @light.position.set(0, 500, 0)
    console.log @


module.exports = Lights
