###
The Hyper namespace contains no state.
@copyright 2014
@author Adu Bhandaru
###

App = require "core/App"


# Set up our namespace
noConflict = window.Hyper

# Get WebGL support
webGL = (->
  try
    !!window.WebGLRenderingContext &&
    !!document.createElement('canvas').getContext('experimental-webgl')
  catch (e)
    false
)()

# Reference to origin
origin = new THREE.Vector3(0, 0, 0)


# Export the following under the Hyper namespace
Hyper = window.Hyper =

  ###
  Expose the base classes.
  ###
  App: App

  ###
  Renderer factory accounts for WebGL support.
  ###
  createRenderer: (width, height) ->
    if Hyper.webGL
      renderer = new THREE.WebGLRenderer(
        antialias: true              # to get smoother output
        preserveDrawingBuffer: true  # to allow screenshot
      )
      renderer.setClearColor(0xFFFFFF, 1)
    else
      renderer = new THREE.CanvasRenderer()
    renderer.setSize(width, height)
    renderer

  ###
  Scene factory given a camera
  ###
  createScene: (camera) ->
    scene = new THREE.Scene()
    scene.add(camera)
    camera.lookAt(scene.position)
    scene


  ###
  The camera factory does a little bit more work for you.
  The options hash can set custom properties for you camera.
  To override any of the defaults below, just set them in the options hash.
  @param {Object} options The options hash.
  @return {THREE.Camera} A camera to render the scene with.
  ###
  createCamera: (options) ->
    options = options or { }
    viewAngle = options.viewAngle || 60
    aspect = options.aspect || 1
    near = options.near || 0.1
    far = options.far || 10000
    # create the camera
    new THREE.PerspectiveCamera(viewAngle, aspect, near, far)


  ###
  Loop an animation function.
  @param {Object} caller The context to run the animate function in.
  @param {Function} renderFn Animation function.
  ###
  renderLoop: (caller, renderFn) ->
    lastUpdate = Date.now()
    render = () ->
      window.requestAnimationFrame(render)
      # Call the passed trigger
      now = Date.now()
      dt =  now - lastUpdate
      lastUpdate = now
      renderFn.apply(caller, [dt])
    render()
