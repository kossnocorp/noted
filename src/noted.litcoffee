# Noted.js v0.1.0

(c) 2013 Sasha Koss.

Noted.js may be freely distributed under the MIT license.

For all details and documentation: http://github.com/kossnocorp/noted

## Dependencies

Noted depends on Backbone.Events or Lisn (TODO). Backbone.Events can be also replaced with jQuery.Event via LisnProxy (TODO).

    Events = if window? then window.Backbone.Events else require('backbone').Events

    extendWithEvents = (obj) ->
      obj[prop] = value for prop, value of Events

    Noted = {}

## Noted.Message

    class Noted.Message

### #constructor(body, group)

      constructor: (body = '', @options = {}) ->
        @_hidden = false
        @setBody(body)
        @listenTo(@, 'hide', @hide)

### #getBody()

      getBody: -> @body

### #setBody()

      setBody: (@body) ->

### #delivered

      delivered: false

### #isDelivered()

      isDelivered: -> @delivered

### #setDelivered()

      setDelivered: (@delivered = true) ->

### #isHideden()

      isHidden: -> @_hidden

### #hide()

      hide: ->
        @_hidden = true

    extendWithEvents(Noted.Message::)


## Noted.Event

    class Noted.Event

### #constructor(name)

      constructor: (@group, @name) ->

### #getName()

      getName: -> @name

### #getGroup()

      getGroup: -> @group

### #setGroup(group)

      setGroup: (@group) ->

    extendWithEvents(Noted.Event::)


## Noted.EventGroup

    class Noted.EventGroup

### #constructor(name)

      constructor: (@name) ->
        @_eventObjs = {}

### #getName()

      getName: -> @name

### #add(event)

      add: (event) ->
        if event instanceof Noted.Event
          @_eventObjs[event.getName()] = event
          event.setGroup(@)
          event
        else
          @_eventObjs[event] = new Noted.Event(@, event)

### #get(name)

      get: (name) ->
        @_eventObjs[name]

### #remove(event)

      remove: (event) ->
        name =  if event instanceof Noted.Event
                  event.name
                else
                  event

        delete @_eventObjs[name]

    extendWithEvents(Noted.EventGroup::)


## Noted.Broker

    class Noted.Broker

### #constructor()

      constructor: ->
        @_eventGroups = {}

### #subscribe(message, callback, [context])

      subscribe: (message, callback, context) ->
        event = @get(message)
        event.getGroup().on(event.getName(), callback, context)

### #publish(message, [content])

      publish: (message, body) ->
        event   = @get(message)
        message = new Noted.Message(body)

        event.getGroup().trigger(event.getName(), message)

        message

### #unsubscribe(message, callback, [context])

      unsubscribe: (message, callback, context) ->
        if message
          event = @get(message)
          event.getGroup().off(event.getName(), callback)
        else
          if context
            for name, group of @_eventGroups
              group.off(undefined, undefined, context)

### #get(message)

      get: (message) ->
        [groupName, eventName] = @parse(message)
        group = @_eventGroups[groupName] ||= new Noted.EventGroup(groupName)
        group.get(eventName) || group.add(eventName)

### #parse(message)

      parse: (message) ->
        [groupName, eventName] = message.match(/(?:(.+):|)(.*)/).slice(1)
        [groupName, eventName || 'all']


## Noted.MessagesList

    class Noted.MessagesList

### #constructor()

      constructor: (broker, context) ->
        @_messages = []

        @_events = {}
        extendWithEvents(@_events)

        @setBroker(broker)
        @setContext(context)

### #getBroker()

      getBroker: -> @broker

### #setBroker()

      setBroker: (@broker) ->

### #getContext()

      getContext: -> @context

### #setContext(other)

      setContext: (@context) ->

### #getMessages()

      getMessages: -> @_messages

### #store(message)

      store: (message) ->
        @_messages.push(message)

        retrigger = (event, args...) ->
          @_events.trigger(event, message, args...)

        message.on('all', retrigger, @)

        return message # WTF?

### #trigger(event, [*args])

      trigger: (event, args...) ->
        for message in @_messages
          message.trigger(event, args...)

### #on(event, callback)

      on: (event, callback) ->
        @_events.on(event, callback, @context)


## Noted.Emitter

    class Noted.Emitter extends Noted.MessagesList

### #emit(message, body)

      emit: (message, body) ->
        message = @broker.publish(message, body)
        @_messages.push(message)
        message


## Noted.Receiver

    class Noted.Receiver extends Noted.MessagesList

      constructor: ->
        super

### #listen(message, callback)

      listen: (message, callback) ->
        receiver = @
        storeMessage = (message, args...) ->
          receiver._messages.push(message)
          callback.apply(@, arguments)

        storeMessage._callback = callback

        @broker.subscribe(message, storeMessage, @context)

### #stop([message], [callback])

Export Noted object to global scope.

      stop: (message, callback) ->
        @broker.unsubscribe(message, callback, @context)

    if window?
      window.Noted = Noted
    else
      module.exports = Noted
