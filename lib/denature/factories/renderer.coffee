THREE = require "three"

flags = require "../util/flags"


class Renderer

  ###
  Renderer factory accounts for WebGL support.
  @param {Number} width The width of the canvas
  @param {Number} height The height of the canvas
  ###
  @create: (width, height) ->
    if flags.webGL
      renderer = new THREE.WebGLRenderer(
        alpha: true
        antialias: true              # to get smoother output
        preserveDrawingBuffer: true  # to allow screenshot
      )
      renderer.setClearColor(0xFFFFFF)
    else
      renderer = new THREE.CanvasRenderer()
    renderer.setSize(width, height)
    renderer


  ###
  Loop an animation function.
  @param {Object} caller The context to run the animate function in.
  @param {Function} renderFn Animation function.
  ###
  @loop: (callback) ->
    lastUpdate = Date.now()
    render = () ->
      self.requestAnimationFrame(render)
      # Call the passed trigger
      now = Date.now()
      dt =  now - lastUpdate
      lastUpdate = now
      callback(dt)
    render()


module.exports = Renderer
