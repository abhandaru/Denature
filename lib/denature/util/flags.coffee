webGL = (->
  try
    !!window.WebGLRenderingContext &&
    !!document.createElement('canvas').getContext('experimental-webgl')
  catch e
    false
)()

module.exports =
  webGL: webGL
