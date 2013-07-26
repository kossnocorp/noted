# Noted.js v0.1.1

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

      constructor: (body = '', id = undefined, @options = {}) ->
        @_hidden =  if id and @options.store == 'cookie' and cookie?
                      cookie.get("noted_#{id}_hidden") || false
                    else if id and @options.store == 'store' and store?
                      store.get("noted_#{id}_hidden") || false
                    else
                      false

        @setBody(body)
        @setId(id)
        @listenTo(@, 'hide', @_hide)

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

### #getId()

      getId: -> @_id

### #setId(id)

      setId: (@_id) ->

### #isHideden()

      isHidden: -> @_hidden

### #hide()

      hide: (doNotStore) ->
        @trigger('hide', doNotStore)

### #_hide()

      _hide: (message, doNotStore = false) ->
        @_hidden = true

        return if doNotStore

        if @options.store == 'cookie' and cookie?
          cookie.set("noted_#{@getId()}_hidden", true)
        else if @options.store == 'store' and store?
          store.set("noted_#{@getId()}_hidden", true)

    extendWithEvents(Noted.Message::)

    Noted.Message::trigger = (event, args...) ->
      Events.trigger.call(@, event, @, args...)


## Noted.Event

    class Noted.Event

### #constructor(name)

      constructor: (@group, @name) ->
        @_messages = []

### #getName()

      getName: -> @name

### #getMessages()

      getMessages: -> @_messages

### #add(message)

      add: (message) ->
        @_messages.push(message)

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

### #all()

      all: ->
        result = []
        for name, event of @_eventObjs
          result.push(event)
        result

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

### #subscribe(message, callback, [context], [options])

      subscribe: (message, callback, context, options = {}) ->
        event = @get(message)

        setDelivered = (args...) ->
          message = if typeof args[0] == 'string'
                      args[1]
                    else
                      args[0]

          message.setDelivered()

          callback.apply(@, args)

        setDelivered._callback = callback

        if options.delayed
          if event.getName() == 'all'
            eventGroups = [event.getGroup()] || @_eventGroups
            for name, group of eventGroups
              for event in group.all()
                for message in event.getMessages()
                  if (not options.undelivered or not message.isDelivered()) and not message.isHidden()
                    setDelivered.call(context, event.getName(), message)
          else
            for message in event.getMessages()
              if (not options.undelivered or not message.isDelivered()) and not message.isHidden()
                setDelivered.call(context, message)

        event.getGroup().on(event.getName(), setDelivered, context)

### #publish(message, [content], [options])

      publish: (message, body, options = {}) ->
        # FIXME
        [__, __, id] = @parse(message)
        event   = @get(message)
        message = new Noted.Message(body, id, options)

        event.add(message)

        unless message.isHidden()
          event.getGroup().trigger(event.getName(), message)

        if options.hideAfter
          hideFn = -> message.hide(if options.storeHide then not options.storeHide)
          setTimeout(hideFn, options.hideAfter)

        message

### #unsubscribe(message, callback, [context])

      unsubscribe: (message, callback, context) ->
        if message
          event = @get(message)
          event.getGroup().off(event.getName(), callback, context)
        else
          for name, group of @_eventGroups
            group.off(null, callback, context)

### #get(message)

      get: (message) ->
        [groupName, eventName, id] = @parse(message)
        group = @_eventGroups[groupName] ||= new Noted.EventGroup(groupName)
        group.get(eventName) || group.add(eventName)

### #parse(message)

      parse: (message) ->
        [groupName, eventName, id] = message.match(/(?:(.+):|)([^#]*)(?:#(.+)|)/).slice(1)
        [groupName, eventName || 'all', id]


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
          @_events.trigger(event, args...)

        message.on('all', retrigger, @)

        return message # WTF?

### #trigger([options], event, [*args])

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

### #on(event, callback)

      on: (event, callback) ->
        @_events.on(event, callback, @context)

### #off([event], [callback])

      off: (event, callback) ->
        @_events.off(event, callback)


## Noted.Emitter

    class Noted.Emitter extends Noted.MessagesList

### #emit(message, body)

      emit: (message, body, options) ->
        message = @broker.publish(message, body, options)
        @_messages.push(message)
        message


## Noted.Receiver

    class Noted.Receiver extends Noted.MessagesList

      constructor: ->
        super

### #listen(message, callback, [options])

      listen: (message, callback, options = {}) ->
        receiver = @

        storeMessage = (message, args...) ->
          receiver._messages.push(message)
          callback.apply(@, arguments)

        # FIXME
        callback._callback = storeMessage

        @broker.subscribe(message, storeMessage, @context, options)

### #stop([message], [callback])

Export Noted object to global scope.

      stop: (message, callback) ->
        @broker.unsubscribe(message, callback?._callback || callback, @context)

    if window?
      window.Noted = Noted
    else
      module.exports = Noted
