describe 'Noted library', ->

  beforeEach ->
    @spy = sinon.spy()
    @global = window
    @global.cookie = undefined

  describe 'Event class', ->

    beforeEach ->
      @group = new Noted.EventGroup('group_name')
      @event = new Noted.Event(@group, 'test')

    describe 'extended with Backbone.Events', ->

      it 'has Backbone.Events functions', ->
        fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
        for fn in fns
          expect(@event[fn]).to.be.defined
          expect(@event[fn]).to.be.a 'function'

    describe 'has name', ->

      describe '#getName()', ->

        it 'returns event name', ->
          expect(@event.getName()).to.be.eq 'test'

    describe 'has name', ->

      describe '#getMessages()', ->

        it 'returns list of messages', ->
          expect(@event.getMessages()).to.be.eql []

      describe '#add()', ->

        it 'adds message to list', ->
          message = new Noted.Message()
          @event.add(message)
          expect(@event.getMessages()).to.be.eql [message]

    describe 'event belongs to event group', ->

      describe '#getGroup()', ->

        it 'returns event group', ->
          expect(@event.getGroup()).to.be.eq @group

      describe '#setGroup(group)', ->

        it 'sets group to event', ->
          group = new Noted.EventGroup('one_more_group')
          @event.setGroup(group)
          expect(@event.getGroup()).to.be.eq group

  describe 'EventGroup class', ->

    beforeEach ->
      @eventGroup = new Noted.EventGroup('test')

    describe 'has name', ->

      it 'returns event name', ->
        expect(@eventGroup.getName()).to.be.eq 'test'

    describe 'can add and remove events', ->

      beforeEach ->
        @event = new Noted.Event(@eventGroup, 'test')

      describe '#add(event)', ->

        it 'adds event', ->
          @eventGroup.add(@event)
          expect(@eventGroup.get('test')).to.be.eq @event

        it 'creates event', ->
          @eventGroup.add('test')
          event = @eventGroup.get('test')
          expect(event).to.be.instanceOf(Noted.Event)
          expect(event.getName()).to.be.eq 'test'

        it 'returns event', ->
          expect(@eventGroup.add(@event)).to.be.instanceOf(Noted.Event)
          expect(@eventGroup.add('asd')).to.be.instanceOf(Noted.Event)

      describe '#all()', ->

        it 'returns all events', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          expect(@eventGroup.all()).to.be.eql [@event, @qwerty]

      describe '#get(name)', ->

        it 'returns event by event name', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          expect(@eventGroup.get('test')).to.be.eq @event
          expect(@eventGroup.get('qwerty')).to.be.eq @qwerty

      describe '#remove(event)', ->

        it 'removes event from collectrion', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          @eventGroup.remove(@qwerty)
          expect(@eventGroup.get('test')).to.be.eq @event
          expect(@eventGroup.get('qwerty')).to.not.exist

        it 'removes event by name from collectrion', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          @eventGroup.remove('qwerty')
          expect(@eventGroup.get('test')).to.be.eq @event
          expect(@eventGroup.get('qwerty')).to.not.exist

    describe 'extended with Backbone.Events', ->

      it 'has Backbone.Events functions', ->
        fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
        for fn in fns
          expect(@eventGroup[fn]).to.be.defined
          expect(@eventGroup[fn]).to.be.a 'function'

  describe 'Broker class', ->

    beforeEach ->
      @broker = new Noted.Broker()

    describe 'publication system', ->

      it 'allows to subscribe to events and deliver messages', ->
        @broker.subscribe('event', @spy)
        @broker.publish('event')
        expect(@spy).to.be.calledOnce

      describe '#subscribe', ->

        it 'uses passed context', ->
          ctxA = spy: @spy
          @broker.subscribe('event', ((message) -> @spy(message)), ctxA)
          message = @broker.publish('event')
          expect(@spy).to.be.calledWith(message)

        it 'allow to subscribe to event group', ->
          @broker.subscribe('group:', @spy)
          message = @broker.publish('group:event')
          message = @broker.publish('group:qwerty')
          expect(@spy).to.be.calledTwice

        it 'can be delayed', ->
          @broker.publish('group:some_message')
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true)
          expect(@spy).to.be.calledTwice

        it 'can be delayed for subscription for event groups', ->
          spyB = sinon.spy()
          @broker.publish('group_a:some_message_a')
          @broker.publish('group_a:some_message_b')
          @broker.subscribe('group_a:', @spy, null, delayed: true)
          @broker.subscribe('group_b:', spyB, null, delayed: true)
          expect(@spy).to.be.calledTwice
          expect(spyB).to.not.be.called

        it 'uses passed context when it delayed', ->
          ctx = spy: @spy
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', (-> @spy()), ctx, delayed: true)
          expect(@spy).to.be.called

        it 'can be delayed for event group', ->
          @broker.publish('group:some_message')
          @broker.publish('group:some_message')
          @broker.subscribe('group:', @spy, null, delayed: true)
          expect(@spy).to.be.calledTwice

        it 'ignore hidden message for delayed subscribe', ->
          message = @broker.publish('group:some_message')
          message.hide()
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true)
          expect(@spy).to.be.calledOnce

        it 'can be delayed only for undelivered messages', ->
          spyB = sinon.spy()
          message = @broker.publish('group:some_message', 34)
          @broker.subscribe('group:some_message', spyB)
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true, undelivered: true)
          expect(@spy).to.be.calledOnce
          expect(@spy).to.be.calledWith(message)

      describe '#publish()', ->

        it 'publish message to subscribers', ->
          @broker.subscribe('event', @spy)
          message = @broker.publish('event')
          expect(@spy).to.be.calledWith(message)

        it 'returns notification instance', ->
          expect(@broker.publish('event')).to.be.instanceOf(Noted.Message)

        it 'marks message as delivered', ->
          @broker.subscribe('event', @spy)
          messageA = @broker.publish('event')
          messageB = @broker.publish('test')
          expect(messageA.isDelivered()).to.be.true
          expect(messageB.isDelivered()).to.be.false

        it 'assigns specified id', ->
          message = @broker.publish('group_name:event_name#uniq_id')
          expect(message.getId()).to.be.eq 'uniq_id'

        it 'add message to event list', ->
          message = @broker.publish('group_name:event_name')
          event   = @broker.get('group_name:event_name')
          expect(event.getMessages()).to.be.eql [message]

        it 'not emit event if message is hidden', ->
          message = new Noted.Message()
          message.hide()
          @broker.subscribe('test', @spy)
          OriginMessage = Noted.Message
          Noted.Message = -> message
          @broker.publish('test', 42)
          expect(@spy).to.not.be.called
          Noted.Message = OriginMessage

        it 'passes options to message constructor', ->
          message = new Noted.Message()
          OriginMessage = Noted.Message
          stub = sinon.stub().returns(message)
          Noted.Message = stub
          options = { qwe: true }
          @broker.publish('group:test#id', 42, options)
          expect(stub).to.be.calledWith(42, 'id', options)
          Noted.Message = OriginMessage

        it 'setup auto hide if options.hideAfter exist', ->
          clock = sinon.useFakeTimers()
          spy = sinon.stub(Noted.Message::, 'hide')
          @broker.publish('event', null, hideAfter: 3000)
          clock.tick(3500)
          expect(spy).to.be.called
          spy.restore()
          clock.restore()

        it 'setup auto hide if options.hideAfter exist', ->
          clock = sinon.useFakeTimers()
          spy = sinon.stub(Noted.Message::, 'hide')
          @broker.publish('event', null, hideAfter: 3000, storeHide: true)
          clock.tick(3500)
          expect(spy).to.be.calledWith(false)
          spy.restore()
          clock.restore()

      describe '#unsubscribe()', ->

        it 'unsubscribes callback from event', ->
          @broker.subscribe('event', @spy)
          @broker.unsubscribe('event', @spy)
          @broker.publish('event')
          expect(@spy).to.not.be.called

        it 'unsubscribes from message', ->
          @broker.subscribe('event', @spy)
          @broker.unsubscribe('event')
          @broker.publish('event')
          expect(@spy).to.not.be.called

        it 'unsubscribes every message for given context', ->
          spyB = sinon.spy()
          ctxA = {}
          ctxB = {}
          @broker.subscribe('event', @spy, ctxA)
          @broker.subscribe('event', spyB, ctxB)
          @broker.unsubscribe(null, null, ctxA)
          @broker.publish('event')
          expect(@spy).to.not.be.called
          expect(spyB).to.be.called

      describe '#get(message)', ->

        it 'returns exist or new event for passed message', ->
          event = @broker.get('group_name:event_name')
          expect(event.getName()).to.be.eq 'event_name'

        it 'returns event for passed message with id', ->
          event = @broker.get('group_name:event_name#uniq_id')
          expect(event.getName()).to.be.eq 'event_name'

      describe '#parse(message)', ->

        it 'returns array where first el is group name', ->
          [groupName] = @broker.parse('group_name:event_name')
          expect(groupName).to.be.eq 'group_name'

        it 'returns array where second el is event name', ->
          [__, eventName] = @broker.parse('group_name:event_name')
          expect(eventName).to.be.eq 'event_name'

        it 'returns "all" event if event name is blank', ->
          [groupName, eventName] = @broker.parse('group_name:')
          expect(groupName).to.be.eq 'group_name'
          expect(eventName).to.be.eq 'all'

        it 'parses message id', ->
          [groupName, eventName, id] = @broker.parse('group_name:event#some_id')
          expect(groupName).to.be.eq 'group_name'
          expect(eventName).to.be.eq 'event'
          expect(id).to.be.eq 'some_id'

  describe 'MessagesList class', ->

    beforeEach ->
      @messagesListCtx = {}
      @broker          = new Noted.Broker()
      @messagesList    = new Noted.MessagesList(@broker, @messagesListCtx)

    describe 'belongs to broker', ->

      describe '#getBroker()', ->

        it 'returns broker', ->
          expect(@messagesList.getBroker()).to.be.eq @broker

      describe '#setBroker(broker)', ->

        it 'sets broker to messagesList', ->
          broker = new Noted.Broker()
          @messagesList.setBroker(broker)
          expect(@messagesList.getBroker()).to.be.eq broker

    describe 'has context', ->

      describe '#getContext()', ->

        it 'returns messagesList context', ->
          expect(@messagesList.getContext()).to.be.eq @messagesListCtx

      describe '#setContext(other)', ->

        it 'sets context to messagesList', ->
          ctx = {}
          @messagesList.setContext(ctx)
          expect(@messagesList.getContext()).to.be.eq ctx

    describe 'stores all messages', ->

      describe '#getMessages()', ->

        it 'returns empty array by default', ->
          expect(@messagesList.getMessages()).to.be.eql []

      describe '#store(message)', ->

        it 'stores message', ->
          message1 = @messagesList.store(new Noted.Message())
          message2 = @messagesList.store(new Noted.Message())
          message3 = @messagesList.store(new Noted.Message())
          messages = @messagesList.getMessages()
          expect(messages[0]).to.be.instanceOf Noted.Message
          expect(messages[0]).to.be.eq message1
          expect(messages[1]).to.be.eq message2
          expect(messages[2]).to.be.eq message3

        it 'returns stored message', ->
          message = new Noted.Message()
          expect(@messagesList.store(message)).to.be.eq message

      describe '#trigger([options], event, [*args])', ->

        it 'trigger events for all stored messages', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          @messagesList.trigger('test', 42)
          expect(@spy).to.be.calledWith(messageA, 42)
          expect(spyB).to.be.calledWith(messageB, 42)

      describe '#on(event, callback, [options])', ->

        it 'listen to stored messages event', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          message.trigger('trololo', 42)
          expect(@spy).to.be.calledWith(message, 42)

        it 'ignores hidden messages', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          messageA.trigger('hide')
          @messagesList.trigger('test', 42)
          expect(@spy).to.not.be.called
          expect(spyB).to.be.calledWith(messageB, 42)

        it 'allow to specify when hidden messages should be trigerred', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          messageA.trigger('hide')
          @messagesList.trigger(hidden: true, 'test', 42)
          expect(@spy).to.be.calledWith(messageA, 42)
          expect(spyB).to.be.calledWith(messageB, 42)

      describe '#off([event], [callback])', ->

        it 'stop listening stored messages', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.off('trololo', @spy)
          message.trigger('trololo', 42)
          expect(@spy).to.not.be.called

        it 'stop listening stored messages by event', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.off('trololo')
          message.trigger('trololo', 42)
          expect(@spy).to.not.be.called

        it 'stop listening all events', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.on('test', @spy)
          @messagesList.off()
          message.trigger('trololo')
          message.trigger('test')
          expect(@spy).to.not.be.called

  describe 'Emitter class', ->

    beforeEach ->
      @broker  = new Noted.Broker()
      @emitter = new Noted.Emitter(@broker)

    describe 'can emit messages', ->

      describe '#emit(message, [body])', ->

        it 'calls publish function at broker', ->
          message = new Noted.Message()
          stub    = sinon.stub(@broker, 'publish').returns(message)

          @emitter.emit('qwerty', 1)
          expect(stub).to.be.calledWith('qwerty', 1)

          stub.restore()

        it 'returns message instance', ->
          message = @emitter.emit('test', 42)
          expect(message.getBody()).to.be.eq 42
          expect(message).to.be.instanceOf Noted.Message

        it 'passes options to broker', ->
          spy = sinon.stub(@broker, 'publish')
          options = { a: 1, b: 2 }
          @emitter.emit('test', 42, options)
          expect(spy).to.be.calledWith('test', 42, options)

  describe 'Receiver class', ->

    beforeEach ->
      @receiverCtx = {}
      @broker  = new Noted.Broker()
      @receiver = new Noted.Receiver(@broker, @receiverCtx)

    describe 'listen broker', ->

      describe '#listen(message, callback)', ->

        it 'listen for messages in broker', ->
          @receiver.listen('some_message', @spy)
          message = @broker.publish('some_message')
          expect(@spy).to.be.called

        it 'stores received messages in list', ->
          @receiver.listen('some_message', @spy)
          message = @broker.publish('some_message')
          messages = @receiver.getMessages()
          expect(messages[0]).to.be.eq message

        it 'uses context', ->
          @receiverCtx.spy = @spy
          @receiver.listen('some_message', -> @spy())
          message = @broker.publish('some_message')
          expect(@spy).to.be.called

        it 'can listen to emitted messages before listen is called', ->
          @broker.publish('some_message')
          @receiver.listen('some_message', @spy, delayed: true)
          expect(@spy).to.be.called

        it 'can listen to emitted and undelivered messages before listen is called', ->
          spyB = sinon.spy()
          message = @broker.publish('some_message', 34)
          @receiver.listen('some_message', spyB)
          @broker.publish('some_message')
          @receiver.listen('some_message', @spy, delayed: true, undelivered: true)
          expect(@spy).to.be.calledOnce
          expect(@spy).to.be.calledWith(message)

      describe '#stop([message], [callback])', ->

        it 'stops listening at all', ->
          @receiver.listen('some_message', @spy)
          @receiver.stop()
          message = @broker.publish('some_message')
          expect(@spy).to.not.be.called

        it 'stops listening all evets but only for given receiver', ->
          spyB = sinon.spy()
          receiverB = new Noted.Receiver(@broker, {})
          @receiver.listen('some_message', @spy)
          receiverB.listen('some_message', spyB)
          @receiver.stop()
          message = @broker.publish('some_message')
          expect(@spy).to.not.be.called
          expect(spyB).to.be.called

        it 'stop listening of message', ->
          spyB = sinon.spy()
          @receiver.listen('some_message', @spy)
          @receiver.listen('some_message', spyB)
          @receiver.stop('some_message')
          message = @broker.publish('some_message')
          expect(@spy).to.not.be.called
          expect(spyB).to.not.be.called

        it 'stop listening of message for given callback', ->
          spyB = sinon.spy()
          @receiver.listen('some_message', @spy)
          @receiver.listen('some_message', spyB)
          @receiver.stop('some_message', @spy)
          message = @broker.publish('some_message')
          expect(@spy).to.not.be.called
          expect(spyB).to.be.called
