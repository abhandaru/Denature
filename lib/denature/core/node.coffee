###
The Node class represents any entity that can trigger or listen for events
inside the canvas app.
###
class Node
  ###
  Give each model instance an id for tracking purposes. This static counter
  determines the next id that will be assigned.
  ###
  @nextId: 0


  ###
  The Node constructor takes no arguments.
  ###
  constructor: () ->
    @id = Node.nextId++
    @root = null
    @parent = null
    @__denature__monitor = null
    @__denature__children = [ ]
    @__denature__listeners = { }


  ###
  Trigger an event at this level of the tree. It will bubble up in the tree
  using the Events module.
  @param {String} name Unique event name.
  @param {Object} payload Any serializable object.
  ###
  trigger: (name, payload) ->
    if @__denature__trigger(name, payload)
      @parent?.trigger(name, payload)
    @


  ###
  Listen for events with `name` fired on `node` (optional)
  @param {Node} node (optional) Specify which node to listen for events on.
    Default: self (this node instance).
  @param {String} name Unique event name.
  @param {Function} handler Function to call when this event is triggered.
  ###
  subscribe: (node, name, handler) ->
    if handler?
      @__denature__subscribe(node, name, handler)
    else
      @__denature__subscribe(@, node, name)
    @


  ###
  Remove all event listeners in all ancestors that were installed by this node.
  Nodes should _never_ listen to events fired on children (let them bubble up).
  @param {Node} node Optional node to remove handlers from. If no node is
    provided, all matching handlers will be removed.
  @param {String} name Optional event name to remove handlers for. If no
    supplemental handle is provided, all handles for this event `name` will
    be removed.
  @param {Function} handler Optional handler to match against. If provided, a
    listener will only be removed if the handler function matches; === equality
  ###
  unsubscribe: (node, name, handler) ->
    if handler?
      pred = (entry) -> entry.node isnt @ or entry.handler isnt handler
      node.__denature__listeners[name] = entries.filter pred, @
    else if name?
      pred = (entry) -> entry.node isnt @ or entry.handler isnt name
      node.__denature__listeners[node] = entries.filter pred, @
    else
      @__denature__unsubscribe(node)
    @


  ###
  Insert a node into this subtree. This determines object hierarchy in the
  scene, and how events bubble up the tree.
  @param {Node} node The node to insert.
  ###
  insert: (node) ->
    node.root = @root
    node.parent = @
    node.__denature__monitor = @root.__denature__monitor if @root
    @__denature__children.push node
    @


  ###
  When a Node is removed, it removes all event handlers installed by itself
  from the event tracking system.
  @param {Node} node The node to remove from children.
  ###
  remove: (node) ->
    @__denature__remove node
    index = @__denature__children.indexOf node
    if index > -1
      @__denature__children.splice(index, 1)
    @


  ###
  Invoke the handlers for the provided `name`, if any. If any handler
  returns false (strictly), then return false to prevent further propagation.
  All matched handlers will fire for this level of the subtree.
  @return {Boolean} false if we should stop propagation.
  ###
  __denature__trigger: (name, payload) ->
    listeners = @__denature__listeners[name]
    return true if not listeners?
    listeners.map(
      (entry) -> entry.handler.apply entry.node, [payload]
    ).every(
      (propagate) -> propagate isnt false
    )


  ###
  Listen for events with `name` fired on `node`. Bind the context of this node
  instance to the handler for client convenience.
  ###
  __denature__subscribe: (node, name, handler) ->
    listeners = node.__denature__listeners
    listeners[name] = [ ] if not listeners[name]?
    listeners[name].push(node: @, handler: handler) if handler?


  ###
  Remove all event listeners installed by this node.
  ###
  __denature__unsubscribe: (name) ->
    pred = (entry) -> entry.node isnt @
    node = @
    while node?
      listeners = node.__denature__listeners
      # Filter out handlers by name routine.
      remove = (name) =>
        list = listeners[name]?.filter pred, @
        if list?.length
          listeners[name] = list
        else
          delete listeners[name]
      # If name provided, only filter for this event name.
      if name?
        remove(name)
      else
        remove(name) for name of listeners
      node = node.parent


  ###
  Remove event bindings for node and all children.
  ###
  __denature__remove: (node) ->
    node.__denature__unsubscribe()
    for child in node.__denature__children
      @__denature__remove(child)


module.exports = Node
