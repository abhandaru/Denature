THREE = require "three"


class Camera

  ###
  The camera factory does a little bit more work for you.
  The options hash can set custom properties for you camera.
  To override any of the defaults below, just set them in the options hash.
  @param {Object} options The options hash.
  @return {THREE.Camera} A camera to render the scene with.
  ###
  @create: (options) ->
    options = options or { }
    viewAngle = options.viewAngle or 60
    aspect = options.aspect or 1
    near = options.near or 0.1
    far = options.far or 10000
    # create the camera
    new THREE.PerspectiveCamera(viewAngle, aspect, near, far)


module.exports = Camera
