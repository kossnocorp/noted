# Noted.js - notification controller for JavaScript

    Noted     = require('../src/noted.litcoffee')

    chai      = require('chai')
    sinon     = require('sinon')
    sinonChai = require('sinon-chai')

    should = chai.should()
    chai.use(sinonChai)

    describe 'Noted library', ->

      beforeEach ->
        @spy = sinon.spy()

# Message class

      describe 'Message class', ->

          beforeEach ->
            @message = new Noted.Message('Test')

## Message body

Body is content message. Not every Message contain body, because is not necessary for simple messages like `"online"` or `"offline"`.

          describe 'body', ->

### #getBody()

            describe '#getBody()', ->

              it 'returns body message', ->
                @message.getBody().should.eq 'Test'

### #setBody(other)

            describe '#setBody()', ->

              it 'apply new body to message', ->
                @message.setBody('42 is the answer.')
                @message.getBody().should.eq '42 is the answer.'

## Backbone.Events behaviour

          describe 'extended with Backbone.Events', ->

            it 'has Backbone.Events functions', ->
              fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
              for fn in fns
                @message[fn].should.be.defined
                @message[fn].should.be.a 'function'

## Delivering status

Message has `delivered` state. `delivered` means "is this message delivered to any listener?". If `delivered` is true well then at least one listener received this message.

          describe 'delivered state', ->

### #isDelivered()

            describe '#isDelivered()', ->

              it 'marks as delivered by default', ->
                @message.isDelivered().should.be.false

              it 'returns actual state of notification', ->
                @message.setDelivered()
                @message.isDelivered().should.be.true

### #setDelivered([status])

            describe '#setDelivered()', ->

              it 'sets delivered to true', ->
                @message.setDelivered()
                @message.isDelivered().should.be.true

              it 'sets delivered to passed argument', ->
                @message.setDelivered()
                @message.setDelivered(false)
                @message.isDelivered().should.be.false

## Hide message

          describe 'can be hidden', ->

### #isHidden()

            describe '#isHidden()', ->

              it 'returns message hidden state', ->
                @message.isHidden().should.be.false

### #hide()

            describe '#hide()', ->

              it 'set hidden state', ->
                @message.hide()
                @message.isHidden().should.be.true

              it 'can be called via "hide" event', ->
                @message.trigger('hide')
                @message.isHidden().should.be.true

              it 'can store hidden state in cookies'

              it 'can store hidden state in localStorage'

              it 'can store hidden state on server'

# Event class

        describe 'Event class', ->

          beforeEach ->
            @group = new Noted.EventGroup('group_name')
            @event = new Noted.Event(@group, 'test')

## Backbone.Events behaviour

          describe 'extended with Backbone.Events', ->

            it 'has Backbone.Events functions', ->
              fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
              for fn in fns
                @event[fn].should.be.defined
                @event[fn].should.be.a 'function'

## Has name

Event name is id.

          describe 'has name', ->

### #getName()

            it 'returns event name', ->
              @event.getName().should.eq 'test'

## Grouping

          describe 'event belongs to event group', ->

### #getGroup()

            describe '#getGroup()', ->

              it 'returns event group', ->
                @event.getGroup().should.eq @group

### #setGroup(group)

            describe '#setGroup(group)', ->

              it 'sets group to event', ->
                group = new Noted.EventGroup('one_more_group')
                @event.setGroup(group)
                @event.getGroup().should.eq group


# EventGroup class

        describe 'EventGroup class', ->

          beforeEach ->
            @eventGroup = new Noted.EventGroup('test')

## It has name

Event name is id.

          describe 'has name', ->

### #getName()

            it 'returns event name', ->
              @eventGroup.getName().should.eq 'test'

## Is a events collection

          describe 'can add and remove events', ->

            beforeEach ->
              @event = new Noted.Event(@eventGroup, 'test')

### #add(event)

            describe '#add(event)', ->

              it 'adds event', ->
                @eventGroup.add(@event)
                @eventGroup.get('test').should.eq @event

              it 'creates event', ->
                @eventGroup.add('test')
                event = @eventGroup.get('test')
                event.should.be.instanceOf(Noted.Event)
                event.getName().should.eq 'test'

              it 'returns event', ->
                @eventGroup.add(@event).should.be.instanceOf(Noted.Event)
                @eventGroup.add('asd').should.be.instanceOf(Noted.Event)

### #get(name)

            describe '#get(name)', ->

              it 'returns event by event name', ->
                @qwerty = new Noted.Event(null, 'qwerty')
                @eventGroup.add(@event)
                @eventGroup.add(@qwerty)
                @eventGroup.get('test').should.eq @event
                @eventGroup.get('qwerty').should.eq @qwerty

### #remove(event)

            describe '#remove(event)', ->

              it 'removes event from collectrion', ->
                @qwerty = new Noted.Event(null, 'qwerty')
                @eventGroup.add(@event)
                @eventGroup.add(@qwerty)
                @eventGroup.remove(@qwerty)
                @eventGroup.get('test').should.eq @event
                should.not.exist @eventGroup.get('qwerty')

              it 'removes event by name from collectrion', ->
                @qwerty = new Noted.Event(null, 'qwerty')
                @eventGroup.add(@event)
                @eventGroup.add(@qwerty)
                @eventGroup.remove('qwerty')
                @eventGroup.get('test').should.eq @event
                should.not.exist @eventGroup.get('qwerty')

## Backbone.Events behaviour

          describe 'extended with Backbone.Events', ->

            it 'has Backbone.Events functions', ->
              fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
              for fn in fns
                @eventGroup[fn].should.be.defined
                @eventGroup[fn].should.be.a 'function'


# Broker class

Broker is a class resposbile to delivering messages to listeners.

      describe 'Broker class', ->

        beforeEach ->
          @broker = new Noted.Broker()

## Publications

``` coffeescript
class Message

  constructor: ->
    @message = broker.publish('messages:new')

  markAsRead: ->
    @message.trigger('read')

class MessagesTab

  constructor: ->
    broker.subscribe('messages:new', @new)
```

        describe 'publication system', ->

          it 'allows to subscribe to events and deliver messages', ->
            @broker.subscribe('event', @spy)
            @broker.publish('event')
            @spy.should.be.calledOnce

### #subscribe(message, callback, [context])

`subscribe` is main function to subscribe to notifications.

First argument is a event name. It also can contain event group name.

Second argument is a callback.

          describe '#subscribe', ->

            it 'uses passed context', ->
              ctxA = spy: @spy
              @broker.subscribe('event', ((message) -> @spy(message)), ctxA)
              message = @broker.publish('event')
              @spy.should.be.calledWith(message)

            it 'allow to subscribe to event group', ->
              @broker.subscribe('group:', @spy)
              message = @broker.publish('group:event')
              message = @broker.publish('group:qwerty')
              @spy.should.be.calledTwice

### #publish(message, [content])

Publish delivering message to every listener. You should specify message as string separated underscores.

          describe '#publish()', ->

            it 'publish message to subscribers', ->
              @broker.subscribe('event', @spy)
              message = @broker.publish('event')
              @spy.should.be.calledWith(message)

            it 'returns notification instance', ->
              @broker.publish('event').should.be.instanceOf(Noted.Message)

### #unsubscribe(message, callback, [context])

          describe '#unsubscribe()', ->

            it 'unsubscribes callback from event', ->
              @broker.subscribe('event', @spy)
              @broker.unsubscribe('event', @spy)
              @broker.publish('event')
              @spy.should.not.be.called

            it 'unsubscribes from message', ->
              @broker.subscribe('event', @spy)
              @broker.unsubscribe('event')
              @broker.publish('event')
              @spy.should.not.be.called

            it 'unsubscribes every message for given context', ->
              spyB = sinon.spy()
              ctxB = {}
              @broker.subscribe('event', @spy, @ctx)
              @broker.subscribe('event', spyB, ctxB)
              @broker.unsubscribe(undefined, undefined, @ctx)
              @broker.publish('event')
              @spy.should.not.be.called


## Events list

Broker can be used as access to events and event groups.

### #get(message)

          describe '#get(message)', ->

            it 'returns exist or new event for passed message', ->
              event = @broker.get('group_name:event_name')
              event.getName().should.eq 'event_name'

## Event groups

### #parse(message)

          describe '#parse(message)', ->

            it 'returns array where first el is group name', ->
              [groupName] = @broker.parse('group_name:event_name')
              groupName.should.eq 'group_name'

            it 'returns array where second el is event name', ->
              [__, eventName] = @broker.parse('group_name:event_name')
              eventName.should.eq 'event_name'

            it 'returns "all" event if event name is blank', ->
              [groupName, eventName] = @broker.parse('group_name:')
              groupName.should.eq 'group_name'
              eventName.should.eq 'all'

## Async delivering

TODO


# MessagesList class

      describe 'MessagesList class', ->

        beforeEach ->
          @messagesListCtx = {}
          @broker          = new Noted.Broker()
          @messagesList    = new Noted.MessagesList(@broker, @messagesListCtx)

## Broker

        describe 'belongs to broker', ->

### #getBroker()

          describe '#getBroker()', ->

            it 'returns broker', ->
              @messagesList.getBroker().should.eq @broker

### #setBroker()

          describe '#setBroker(broker)', ->

            it 'sets broker to messagesList', ->
              broker = new Noted.Broker()
              @messagesList.setBroker(broker)
              @messagesList.getBroker().should.eq broker

## Context

        describe 'has context', ->

### #getContext()

          describe '#getContext()', ->

            it 'returns messagesList context', ->
              @messagesList.getContext().should.eq @messagesListCtx

### #setContext(other)

          describe '#setContext(other)', ->

            it 'sets context to messagesList', ->
              ctx = {}
              @messagesList.setContext(ctx)
              @messagesList.getContext().should.eq ctx

## Stored messages

        describe 'stores all messages', ->

### #getMessages()

          describe '#getMessages()', ->

            it 'returns empty array by default', ->
              @messagesList.getMessages().should.eql []

### #store()

          describe '#store(message)', ->

            it 'stores message', ->
              message1 = @messagesList.store(new Noted.Message())
              message2 = @messagesList.store(new Noted.Message())
              message3 = @messagesList.store(new Noted.Message())
              messages = @messagesList.getMessages()
              messages[0].should.be.instanceOf Noted.Message
              messages[0].should.be.eq message1
              messages[1].should.be.eq message2
              messages[2].should.be.eq message3

            it 'returns stored message', ->
              message = new Noted.Message()
              @messagesList.store(message).should.eq message

### #retrigger()

### #trigger(event, [*args])

          describe '#trigger(event, [*args])', ->

            it 'trigger events for all stored messages', ->
              spyB = sinon.spy()
              messageA = @messagesList.store(new Noted.Message())
              messageB = @messagesList.store(new Noted.Message())
              messageA.on('test', @spy)
              messageB.on('test', spyB)
              @messagesList.trigger('test', 42)
              @spy.should.be.calledWith(42)
              spyB.should.be.calledWith(42)

            it 'ignores hidden messages'

            it 'allow to specify when hidden messages should be trigerred'

### #on(event)

          describe '#on(event, callback)', ->

            it 'listen to stored messages event', ->
              message = new Noted.Message()
              @messagesList.store(message)
              @messagesList.on('trololo', @spy)
              message.trigger('trololo', 42)
              @spy.should.be.calledWith(message, 42)

            it 'ignores hidden messages'

            it 'allow to specify when hidden messages should be trigerred'

### #off([event], [callback])

          describe '#off([event], [callback])', ->

            it 'stop listening stored messages'

# Emitter class

      describe 'Emitter class', ->

        beforeEach ->
          @broker  = new Noted.Broker()
          @emitter = new Noted.Emitter(@broker)

## Emit

        describe 'can emit messages', ->

### #emit(message, [body])

          describe '#emit(message, [body])', ->

            it 'calls publish function at broker', ->
              message = new Noted.Message()
              stub    = sinon.stub(@broker, 'publish').returns(message)

              @emitter.emit('qwerty', 1)
              stub.should.be.calledWith('qwerty', 1)

              stub.restore()

            it 'returns message instance', ->
              message = @emitter.emit('test', 42)
              message.getBody().should.eq 42
              message.should.be.instanceOf Noted.Message


# Receiver class

      describe 'Receiver class', ->

        beforeEach ->
          @receiverCtx = {}
          @broker  = new Noted.Broker()
          @receiver = new Noted.Receiver(@broker, @receiverCtx)

## Listen

        describe 'listen broker', ->

### #listen(message, callback)

          describe '#listen(message, callback)', ->

            it 'listen for messages in broker', ->
              @receiver.listen('some_message', @spy)
              message = @broker.publish('some_message')
              @spy.should.be.called

            it 'stores received messages in list', ->
              @receiver.listen('some_message', @spy)
              message = @broker.publish('some_message')
              messages = @receiver.getMessages()
              messages[0].should.eq message

            it 'uses context', ->
              @receiverCtx.spy = @spy
              @receiver.listen('some_message', -> @spy())
              message = @broker.publish('some_message')
              @spy.should.be.called

### #stop([message], [callback])

          describe '#stop([message], [callback])', ->

            it 'stops listening at all', ->
              @receiver.listen('some_message', @spy)
              @receiver.stop()
              message = @broker.publish('some_message')
              @spy.should.not.be.called

            it 'stops listening all evets but only for given receiver', ->
              spyB = sinon.spy()
              receiverB = new Noted.Receiver(@broker, {})
              @receiver.listen('some_message', @spy)
              receiverB.listen('some_message', spyB)
              @receiver.stop()
              message = @broker.publish('some_message')
              @spy.should.not.be.called
              spyB.should.be.called

            it 'stop listening of message', ->
              spyB = sinon.spy()
              @receiver.listen('some_message', @spy)
              @receiver.listen('some_message', spyB)
              @receiver.stop('some_message')
              message = @broker.publish('some_message')
              @spy.should.not.be.called
              spyB.should.not.be.called

            it 'stop listening of message for given callback', ->
              spyB = sinon.spy()
              @receiver.listen('some_message', @spy)
              @receiver.listen('some_message', spyB)
              @receiver.stop('some_message', @spy)
              message = @broker.publish('some_message')
              @spy.should.not.be.called
              spyB.should.be.called

