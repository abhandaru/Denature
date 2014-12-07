class Event
  ###
  Create a new event.
  @param {window.Event} native A reference to the native event.
  ###
  constructor: (@native) ->


  ###
  Only works for scroll events because the fields will not be defined
  otherwise.
  @return {Number} Scrolling distance for this event instance. Note this
    may not be cross-platform normalized.
  ###
  scrollDelta: () ->
    isWheel = this.native.wheelDeltaX?
    delta = new THREE.Vector2(@native.wheelDeltaX, @native.wheelDeltaY)
    (isWheel and delta) or null


module.exports = Event
