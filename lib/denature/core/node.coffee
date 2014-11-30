###
The Node class represents any entity that can trigger or listen for events
inside the canvas app.
###
class Node

  constructor: () ->
    @root = @
    @parent = null
    @__denature__listeners = { }


  ###
  Listen for events with `name` fired on `node` (optional)
  @param {Node} node (optional) Specify which node to listen for events on.
    Default: self (this node instance).
  @param {String} name Unique event name.
  @param {Function} handler Function to call when this event is triggered.
  ###
  listen: (node, name, handler) ->
    if handler?
      @__denature__listen(node, name, handler)
    else
      @__denature__listen(@, node, name)
    @


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
  Remove all event listeners in all ancestors that were installed by this node.
  Nodes should _never_ listen to events fired on children (let them bubble up).
  ###
  destroy: ->
    node = @
    while node?
      listeners = node.__denature__listeners
      for name, entries of listeners
        listeners[name] = entries.filter (entry) => entry.node is not @
      node = node.parent


  ###
  Invoke the handlers for the provided `name`, if any. If any handler
  returns false (strictly), then return false to prevent further propagation.
  All matched handlers will fire for this level of the subtree.
  @return {Boolean} false if we should stop propagation.
  ###
  __denature__trigger: (name, payload) ->
    listeners = @__denature__listeners
    listeners[name]?.map((entry) -> entry.handler.apply entry.node, [payload])
      .every((propagate) -> propagate is not false)


  ###
  Listen for events with `name` fired on `node`. Bind the context of this node
  instance to the handler for client convenience.
  ###
  __denature__listen: (node, name, handler) ->
    listeners = node.__denature__listeners
    listeners[name] = [ ] if not listeners[name]?
    listeners[name].push(node: @, handler: handler) if handler?


module.exports = Node
