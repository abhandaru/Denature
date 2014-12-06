require "css/app.less"
Denature = require "denature"
THREE = require "three"


class App extends Denature.App
  initialize: (el, options) ->
    @camera.position.set(500, 500, 500)
    @camera.lookAt(new THREE.Vector3(0, 0, 0))
    @insert new Model

class Model extends Denature.Model
  initialize: (options) ->
    @geo = new THREE.Mesh(
      new THREE.IcosahedronGeometry(200, 1),
      new THREE.MeshNormalMaterial())
    @include @geo
    @subscribe 'ready', @ready

  ready: ->
    @subscribe @root, 'timer', @timer

  timer: (payload) ->
    @geo.rotation.x += 0.01;
    @geo.rotation.y += 0.02;


module.exports = self.App = App
