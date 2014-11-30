THREE = require "three"


class Scene

  ###
  Scene factory given a camera
  @param {THREE.Camera} camera The camera to insert into the scene
  ###
  @create: (camera) ->
    scene = new THREE.Scene()
    scene.add(camera)
    camera.lookAt(scene.position)
    scene


module.exports = Scene
