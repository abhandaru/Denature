THREE = require "three"

Event = require "../events/event"
util = require "../util/util"


class Monitor
  ###
  List of all built in event names. These events can be triggered by the
  user when interacting with the canvas, and by the framework thusly.
  It is advised you do not use these names for events.
  ###
  @events =
    LEFT_CLICK   : "click"
    MOUSE_MOVE   : "mousemove"
    MOUSE_DOWN   : "mousedown"
    MOUSE_UP     : "mouseup"
    MOUSE_OVER   : "mouseover"
    MOUSE_OUT    : "mouseout"
    MOUSE_DRAG   : "mousedrag"
    MOUSE_DROP   : "mousedrop"
    MOUSE_SCROLL : "scroll"
    READY        : "ready"
    RIGHT_CLICK  : "rightclick"


  ###
  Monitor constructor. Given an application root and a DOM element, listen
  to and convert events from native 2D interaction to 3D interaction within the
  the canvas.
  @param {App} root The highest level node to bubble events to.
  @param {HTMLElement} el The containing div of the app canvas.
  ###
  constructor: (@root, @el) ->
    # Tracking data structures
    @models = { }
    @objects = [ ]

    # Modify container so it can receive scroll events
    @el.style.overflow = "auto"

    # Initial event tracking states
    @isMouseDown = false
    @lastMousePosition = new THREE.Vector2(0, 0)
    @lastOver = null
    @lastClick = null
    @lastDrag = null

    # Attach event listeners to given element
    @attachListeners @el


  ###
  Track events for an additional model. This registers the model with the
  monitor as well as it's same-level THREE objects.
  @param {Model} model The model to track events for.
  ###
  track: (model) ->
    children = model.__denature__includes
    objects = [ ]
    for child in children
      child.__denature__model = model  # HACK: And I'm not sorry
      objects.push child
    @models[model.id] = objects
    @computeObjects()


  ###
  Just a proxy for track as of now. Later we can upgrade to a more incremental
  approach for efficiency.
  @param {Model} model The model to track events for.
  ###
  update: (model) -> @track model


  ###
  Stop tracking the given model.
  @param {Model} model The model to remove event tracking for.
  ###
  forget: (model) ->
    delete @models[model.id]
    @computeObjects()


  ###
  Given the current models registered, compute the new list of objects to
  track for event monitoring.
  ###
  computeObjects: ->
    list = (objects for id, objects of @models)
    flattened = [ ]
    @objects = flattened.concat.apply(flattened, list)


  ###
  Attach event listeners to the given element and generate the appropriate
  handlers for each event.
  @param {HTMLElement} el The container element.
  ###
  attachListeners: (el) ->
    el.addEventListener('click', @decorateHandler(@click), false)
    el.addEventListener('mousedown', @decorateHandler(@mouseDown), false)
    el.addEventListener('mouseup', @decorateHandler(@mouseUp), false)
    el.addEventListener('mousemove', @decorateHandler(@mouseMove), false)
    el.addEventListener('mousewheel', @decorateHandler(@mouseWheel), false)
    el.addEventListener('contextmenu', @decorateHandler(@contextMenu), false)


  ###
  Wrap each raw event handler with the following code. This reuses the code
  for scene intersection and model selection/deselection.
  @param {Function} handler The event handler to wrap.
  ###
  decorateHandler: (handler) -> (event) =>
    event.preventDefault()
    e = new Event(event)

    # Extract the 2D information.
    coords = new THREE.Vector2(event.layerX, event.layerY)
    e.point2 = coords
    e.delta2 = coords.clone().sub(@lastMousePosition)

    # See if we hit anything in the scene.
    targets = @getTargets(coords.x, coords.y)
    if targets.length
      target = targets[0];
      e.distance = target.distance
      e.point3 = target.point
      e.face = target.face
      e.object = target.object
      e.target = target.object.__denature__model
    else
      e.target = @root

    # Run handler and check state
    ret = handler.apply(@, [e])
    @checkFocus(event, e.target, coords)
    @lastMousePosition.set(coords.x, coords.y)
    ret


  ###
  Find objects in the scene that intersect with the ray cast from coordinates
  given. This uses the cursor (x,y), the camera position and direction, and a
  a raycaster.
  @param {Number} x The x position of the cursor
  @param {Number} y The y position of the cursor
  ###
  getTargets: (x, y) ->
    camera = @root.camera
    vector = new THREE.Vector3(
      (x / @root.width) * 2 - 1,
      -(y / @root.height) * 2 + 1,
      0.5
    )
    vector.unproject(camera)
    raycaster = new THREE.Raycaster(
      camera.position,
      vector.sub(camera.position).normalize()
    )
    raycaster.intersectObjects(@objects, true);


  ###
  Update the event tracking state with regards to target selection or
  deselection. Generates new events if needed.
  @param {self.Event} event The native event.
  @param {Model} current The current model which is being targeted.
  @param {THREE.Vector2} coords The coordinates of the original cursor event.
  ###
  checkFocus: (event, current, coords) ->
    focus = @lastOver
    ret = false
    if focus? and (not current? or focus isnt current)
      e = new Event(event)
      e.point2 = coords.clone()
      e.target = focus
      ret = focus.trigger(Monitor.EVENTS_MOUSEOUT, e)
    # Update the focus
    @lastOver = current
    ret


  ###
  The following functions intercept native DOM events and map them to the
  correct events in the 3D scene. Each takes in a derived Denature.Event.
  ###
  click: (event) ->
    @lastClick = event.target
    event.target.trigger(Monitor.events.LEFT_CLICK, event)


  mouseDown: (event) ->
    @lastClick = event.target
    @isMouseDown = true
    event.target.trigger(Monitor.events.MOUSE_DOWN, event)


  mouseUp: (event) ->
    @isMouseDown = false
    ret = event.target.trigger(Monitor.events.MOUSE_UP, event)
    # Run drop handler.
    if @lastDrag?
      @lastDrag.trigger(Monitor.events.MOUSE_DROP, event)
      @lastDrag = null
    # Clean up.
    ret


  mouseMove: (event) ->
    target = event.target
    ret = target.trigger(Monitor.events.MOUSE_MOVE, event)
    # Check for change of focus (hover).
    if @lastOver isnt target
      @lastOver?.trigger(Monitor.events.MOUSE_OUT, event)
      target.trigger(Monitor.events.MOUSE_OVER, event)
    # Check for drags.
    if @isMouseDown and @lastClick is target
      @lastDrag = target
      target.trigger(Monitor.events.MOUSE_DRAG, event)
    else if @isMouseDown and @lastDrag?
      @lastDrag.trigger(Monitor.events.MOUSE_DRAG, event)
    # Clean up by returning original handler result
    ret


  mouseWheel: (event) ->
    event.target.trigger(Monitor.events.MOUSE_SCROLL, event)


  contextMenu: (event) ->
    event.target.trigger(Monitor.events.RIGHT_CLICK, event)


module.exports = Monitor
