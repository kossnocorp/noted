Events = if window? then window.Backbone.Events else require('backbone').Events

extendWithEvents = (obj) ->
  obj[prop] = value for prop, value of Events

Noted = {}

class Noted.Message

  constructor: (body = '', id = undefined, @options = {}) ->
    @_hidden = @_isHidden(id)
    @setBody(body)
    @setId(id)
    @listenTo(@, 'hide', @_hide)

  getBody: -> @body

  setBody: (@body) ->

  delivered: false

  isDelivered: -> @delivered

  setDelivered: (@delivered = true) ->

  getId: -> @_id

  setId: (@_id) ->

  isHidden: -> @_hidden

  hide: (doNotStore) ->
    @trigger('hide', doNotStore)

  _hide: (message, doNotStore = false) ->
    @_hidden = true

    return if doNotStore

    if @options.store == 'cookie' and cookie?
      cookie.set("noted_#{@getId()}_hidden", true)
    else if @options.store == 'store' and store?
      store.set("noted_#{@getId()}_hidden", true)

  _isHidden: (id) ->
    if id and storage = @_storage()
      hiddenKey = "noted_#{id}_hidden"
      storage.get(hiddenKey) or false
    else
      false

  _storage: ->
    if @options.store is 'cookie' and cookie?
      cookie
    else if @options.store is 'store' and store?
      store
    else
      null

extendWithEvents(Noted.Message::)

Noted.Message::trigger = (event, args...) ->
  Events.trigger.call(@, event, @, args...)

class Noted.Event

  constructor: (@group, @name) ->
    @_messages = []

  getName: -> @name

  getMessages: -> @_messages

  add: (message) ->
    @_messages.push(message)

  getGroup: -> @group

  setGroup: (@group) ->

extendWithEvents(Noted.Event::)

class Noted.EventGroup

  constructor: (@name) ->
    @_eventObjs = {}

  getName: -> @name

  add: (event) ->
    if event instanceof Noted.Event
      @_eventObjs[event.getName()] = event
      event.setGroup(@)
      event
    else
      @_eventObjs[event] = new Noted.Event(@, event)

  all: -> event for name, event of @_eventObjs

  get: (name) ->
    @_eventObjs[name]

  remove: (event) ->
    name = if event instanceof Noted.Event then event.name else event
    delete @_eventObjs[name]

extendWithEvents(Noted.EventGroup::)

class Noted.Broker

  MESSAGE_PATTERN = /(?:(.+):|)([^#]*)(?:#(.+)|)/

  constructor: ->
    @_eventGroups = {}

  subscribe: (message, callback, context, options = {}) ->
    event = @get(message)

    setDelivered = (args...) ->
      message = if typeof args[0] is 'string' then args[1] else args[0]
      message.setDelivered()

      callback.apply(@, args)

    setDelivered._callback = callback

    if options.delayed
      if event.getName() == 'all'
        eventGroups = [event.getGroup()] || @_eventGroups
        for own name, group of eventGroups
          for event in group.all()
            for message in event.getMessages()
              if (not options.undelivered or not message.isDelivered()) and not message.isHidden()
                setDelivered.call(context, event.getName(), message)
      else
        for message in event.getMessages()
          if (not options.undelivered or not message.isDelivered()) and not message.isHidden()
            setDelivered.call(context, message)

    event.getGroup().on(event.getName(), setDelivered, context)

  publish: (message, body, options = {}) ->
    id = @parse(message)[2]
    event = @get(message)
    message = new Noted.Message(body, id, options)

    event.add(message)

    unless message.isHidden()
      event.getGroup().trigger(event.getName(), message)

    if options.hideAfter
      hideFn = -> message.hide(if options.storeHide then not options.storeHide)
      setTimeout(hideFn, options.hideAfter)

    message

  unsubscribe: (message, callback, context) ->
    if message
      event = @get(message)
      event.getGroup().off(event.getName(), callback, context)
    else
      for name, group of @_eventGroups
        group.off(null, callback, context)

  get: (message) ->
    [groupName, eventName, id] = @parse(message)
    group = @_eventGroups[groupName] ||= new Noted.EventGroup(groupName)
    group.get(eventName) || group.add(eventName)

  parse: (message) ->
    [groupName, eventName, id] = message.match(MESSAGE_PATTERN).slice(1)
    [groupName, eventName || 'all', id]

class Noted.MessagesList

  constructor: (broker, context) ->
    @_messages = []

    @_events = {}
    extendWithEvents(@_events)

    @setBroker(broker)
    @setContext(context)

  getBroker: -> @broker

  setBroker: (@broker) ->

  getContext: -> @context

  setContext: (@context) ->

  getMessages: -> @_messages

  store: (message) ->
    @_messages.push(message)

    retrigger = (event, args...) ->
      @_events.trigger(event, args...)

    message.on('all', retrigger, @)

    message

  trigger: (maybeOptions, maybeEvent, maybeArgs...) ->
    if typeof maybeOptions == 'string'
      options = {}
      event   = maybeOptions
      args    = [maybeEvent].concat(maybeArgs)
    else
      options = maybeOptions
      event   = maybeEvent
      args    = maybeArgs

    messages =  if options.hidden
                  @_messages
                else
                  result = []
                  for message in @_messages
                    result.push(message) unless message.isHidden()
                  result

    for message in messages
      message.trigger(event, args...)

  on: (event, callback) ->
    @_events.on(event, callback, @context)

  off: (event, callback) ->
    @_events.off(event, callback)

class Noted.Emitter extends Noted.MessagesList

  emit: (message, body, options) ->
    message = @broker.publish(message, body, options)
    @_messages.push(message)
    message

class Noted.Receiver extends Noted.MessagesList

  constructor: ->
    super

  listen: (message, callback, options = {}) ->
    receiver = @

    storeMessage = (message, args...) ->
      receiver._messages.push(message)
      callback.apply(@, arguments)

    # FIXME
    callback._callback = storeMessage

    @broker.subscribe(message, storeMessage, @context, options)

  stop: (message, callback) ->
    @broker.unsubscribe(message, callback?._callback || callback, @context)

if window?
  window.Noted = Noted
else
  module.exports = Noted
