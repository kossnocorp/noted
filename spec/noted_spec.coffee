describe 'Noted library', ->

  beforeEach ->
    @spy = sinon.spy()
    global.cookie = undefined

  describe 'Message class', ->

    beforeEach ->
      @message = new Noted.Message('Test')

    describe 'body', ->

      describe '#getBody()', ->

        it 'returns body message', ->
          @message.getBody().should.eq 'Test'

      describe '#setBody()', ->

        it 'apply new body to message', ->
          @message.setBody('42 is the answer.')
          @message.getBody().should.eq '42 is the answer.'

    describe 'extended with Backbone.Events', ->

      it 'has Backbone.Events functions', ->
        fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
        for fn in fns
          @message[fn].should.be.defined
          @message[fn].should.be.a 'function'

      it 'overries default Backbone.Events.trigger behaviour and pass self as first argument', ->
        @message.on('event', @spy)
        @message.trigger('event', 'test')
        @spy.should.be.calledWith(@message, 'test')

    describe 'delivered state', ->

      describe '#isDelivered()', ->

        it 'marks as delivered by default', ->
          @message.isDelivered().should.be.false

        it 'returns actual state of notification', ->
          @message.setDelivered()
          @message.isDelivered().should.be.true

      describe '#setDelivered()', ->

        it 'sets delivered to true', ->
          @message.setDelivered()
          @message.isDelivered().should.be.true

        it 'sets delivered to passed argument', ->
          @message.setDelivered()
          @message.setDelivered(false)
          @message.isDelivered().should.be.false

    describe 'message has id', ->

      describe '#getId()', ->

        it 'returns id', ->
          should.not.exist @message.getId()

      describe '#setId(id)', ->

        it 'sets id', ->
          @message.setId(42)
          @message.getId().should.eq 42

    describe 'can be hidden', ->

      describe '#isHidden()', ->

        it 'returns message hidden state', ->
          @message.isHidden().should.be.false

      describe '#hide()', ->

        it 'set hidden state', ->
          @message.hide()
          @message.isHidden().should.be.true

        it 'can be called via "hide" event', ->
          @message.trigger('hide')
          @message.isHidden().should.be.true

        it 'should trigger hide event', ->
          @message.on('hide', @spy)
          @message.hide()
          @spy.should.be.called

        describe 'cookie usage', ->

          beforeEach ->
            global.cookie =
              set: sinon.stub()
              get: sinon.stub()

          afterEach ->
            global.cookie = undefined

          it 'can read hidden state in cookies', ->
            stub = sinon.stub().returns(true)
            cookie.get = stub

            message = new Noted.Message(42, 'trololo', store: 'cookie')
            message.isHidden().should.be.true
            stub.should.be.calledWith('noted_trololo_hidden')

          it 'can store hidden state in cookies', ->
            message = new Noted.Message(42, 'trololo', store: 'cookie')
            message.hide()
            cookie.set.should.be.calledWith('noted_trololo_hidden', true)

          it 'ignores hide if first argument is true', ->
            messageA = new Noted.Message(42, 'trololo', store: 'cookie')
            messageA.hide(true)
            messageB = new Noted.Message(42, 'trololo', store: 'cookie')
            messageB.trigger('hide', true)
            cookie.set.should.not.be.called

        describe 'localStorage usage', ->

          beforeEach ->
            global.store =
              set: sinon.stub()
              get: sinon.stub()

          afterEach ->
            global.store = undefined

          it 'can read hidden state in stores', ->
            stub = sinon.stub().returns(true)
            store.get = stub

            message = new Noted.Message(42, 'trololo', store: 'store')
            message.isHidden().should.be.true
            stub.should.be.calledWith('noted_trololo_hidden')

          it 'can store hidden state in stores', ->
            message = new Noted.Message(42, 'trololo', store: 'store')
            message.hide()
            store.set.should.be.calledWith('noted_trololo_hidden', true)

  describe 'Event class', ->

    beforeEach ->
      @group = new Noted.EventGroup('group_name')
      @event = new Noted.Event(@group, 'test')

    describe 'extended with Backbone.Events', ->

      it 'has Backbone.Events functions', ->
        fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
        for fn in fns
          @event[fn].should.be.defined
          @event[fn].should.be.a 'function'

    describe 'has name', ->

      describe '#getName()', ->

        it 'returns event name', ->
          @event.getName().should.eq 'test'

    describe 'has name', ->

      describe '#getMessages()', ->

        it 'returns list of messages', ->
          @event.getMessages().should.eql []

      describe '#add()', ->

        it 'adds message to list', ->
          message = new Noted.Message()
          @event.add(message)
          @event.getMessages().should.eql [message]

    describe 'event belongs to event group', ->

      describe '#getGroup()', ->

        it 'returns event group', ->
          @event.getGroup().should.eq @group

      describe '#setGroup(group)', ->

        it 'sets group to event', ->
          group = new Noted.EventGroup('one_more_group')
          @event.setGroup(group)
          @event.getGroup().should.eq group

  describe 'EventGroup class', ->

    beforeEach ->
      @eventGroup = new Noted.EventGroup('test')

    describe 'has name', ->

      it 'returns event name', ->
        @eventGroup.getName().should.eq 'test'

    describe 'can add and remove events', ->

      beforeEach ->
        @event = new Noted.Event(@eventGroup, 'test')

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

      describe '#all()', ->

        it 'returns all events', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          @eventGroup.all().should.eql [@event, @qwerty]

      describe '#get(name)', ->

        it 'returns event by event name', ->
          @qwerty = new Noted.Event(null, 'qwerty')
          @eventGroup.add(@event)
          @eventGroup.add(@qwerty)
          @eventGroup.get('test').should.eq @event
          @eventGroup.get('qwerty').should.eq @qwerty

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

    describe 'extended with Backbone.Events', ->

      it 'has Backbone.Events functions', ->
        fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
        for fn in fns
          @eventGroup[fn].should.be.defined
          @eventGroup[fn].should.be.a 'function'

  describe 'Broker class', ->

    beforeEach ->
      @broker = new Noted.Broker()

    describe 'publication system', ->

      it 'allows to subscribe to events and deliver messages', ->
        @broker.subscribe('event', @spy)
        @broker.publish('event')
        @spy.should.be.calledOnce

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

        it 'can be delayed', ->
          @broker.publish('group:some_message')
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true)
          @spy.should.be.calledTwice

        it 'can be delayed for subscription for event groups', ->
          spyB = sinon.spy()
          @broker.publish('group_a:some_message_a')
          @broker.publish('group_a:some_message_b')
          @broker.subscribe('group_a:', @spy, null, delayed: true)
          @broker.subscribe('group_b:', spyB, null, delayed: true)
          @spy.should.be.calledTwice
          spyB.should.not.be.called

        it 'uses passed context when it delayed', ->
          ctx = spy: @spy
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', (-> @spy()), ctx, delayed: true)
          @spy.should.be.called

        it 'can be delayed for event group', ->
          @broker.publish('group:some_message')
          @broker.publish('group:some_message')
          @broker.subscribe('group:', @spy, null, delayed: true)
          @spy.should.be.calledTwice

        it 'ignore hidden message for delayed subscribe', ->
          message = @broker.publish('group:some_message')
          message.hide()
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true)
          @spy.should.be.calledOnce

        it 'can be delayed only for undelivered messages', ->
          spyB = sinon.spy()
          message = @broker.publish('group:some_message', 34)
          @broker.subscribe('group:some_message', spyB)
          @broker.publish('group:some_message')
          @broker.subscribe('group:some_message', @spy, null, delayed: true, undelivered: true)
          @spy.should.be.calledOnce
          @spy.should.be.calledWith(message)

      describe '#publish()', ->

        it 'publish message to subscribers', ->
          @broker.subscribe('event', @spy)
          message = @broker.publish('event')
          @spy.should.be.calledWith(message)

        it 'returns notification instance', ->
          @broker.publish('event').should.be.instanceOf(Noted.Message)

        it 'marks message as delivered', ->
          @broker.subscribe('event', @spy)
          messageA = @broker.publish('event')
          messageB = @broker.publish('test')
          messageA.isDelivered().should.be.true
          messageB.isDelivered().should.be.false

        it 'assigns specified id', ->
          message = @broker.publish('group_name:event_name#uniq_id')
          message.getId().should.eq 'uniq_id'

        it 'add message to event list', ->
          message = @broker.publish('group_name:event_name')
          event   = @broker.get('group_name:event_name')
          event.getMessages().should.eql [message]

        it 'not emit event if message is hidden', ->
          message = new Noted.Message()
          message.hide()
          @broker.subscribe('test', @spy)
          OriginMessage = Noted.Message
          Noted.Message = -> message
          @broker.publish('test', 42)
          @spy.should.not.be.called
          Noted.Message = OriginMessage

        it 'passes options to message constructor', ->
          message = new Noted.Message()
          OriginMessage = Noted.Message
          stub = sinon.stub().returns(message)
          Noted.Message = stub
          options = { qwe: true }
          @broker.publish('group:test#id', 42, options)
          stub.should.be.calledWith(42, 'id', options)
          Noted.Message = OriginMessage

        it 'setup auto hide if options.hideAfter exist', ->
          clock = sinon.useFakeTimers()
          spy = sinon.stub(Noted.Message::, 'hide')
          @broker.publish('event', null, hideAfter: 3000)
          clock.tick(3500)
          spy.should.be.called
          spy.restore()
          clock.restore()

        it 'setup auto hide if options.hideAfter exist', ->
          clock = sinon.useFakeTimers()
          spy = sinon.stub(Noted.Message::, 'hide')
          @broker.publish('event', null, hideAfter: 3000, storeHide: true)
          clock.tick(3500)
          spy.should.be.calledWith(false)
          spy.restore()
          clock.restore()

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
          ctxA = {}
          ctxB = {}
          @broker.subscribe('event', @spy, ctxA)
          @broker.subscribe('event', spyB, ctxB)
          @broker.unsubscribe(null, null, ctxA)
          @broker.publish('event')
          @spy.should.not.be.called
          spyB.should.be.called

      describe '#get(message)', ->

        it 'returns exist or new event for passed message', ->
          event = @broker.get('group_name:event_name')
          event.getName().should.eq 'event_name'

        it 'returns event for passed message with id', ->
          event = @broker.get('group_name:event_name#uniq_id')
          event.getName().should.eq 'event_name'

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

        it 'parses message id', ->
          [groupName, eventName, id] = @broker.parse('group_name:event#some_id')
          groupName.should.eq 'group_name'
          eventName.should.eq 'event'
          id.should.eq 'some_id'

  describe 'MessagesList class', ->

    beforeEach ->
      @messagesListCtx = {}
      @broker          = new Noted.Broker()
      @messagesList    = new Noted.MessagesList(@broker, @messagesListCtx)

    describe 'belongs to broker', ->

      describe '#getBroker()', ->

        it 'returns broker', ->
          @messagesList.getBroker().should.eq @broker

      describe '#setBroker(broker)', ->

        it 'sets broker to messagesList', ->
          broker = new Noted.Broker()
          @messagesList.setBroker(broker)
          @messagesList.getBroker().should.eq broker

    describe 'has context', ->

      describe '#getContext()', ->

        it 'returns messagesList context', ->
          @messagesList.getContext().should.eq @messagesListCtx

      describe '#setContext(other)', ->

        it 'sets context to messagesList', ->
          ctx = {}
          @messagesList.setContext(ctx)
          @messagesList.getContext().should.eq ctx

    describe 'stores all messages', ->

      describe '#getMessages()', ->

        it 'returns empty array by default', ->
          @messagesList.getMessages().should.eql []

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

      describe '#trigger([options], event, [*args])', ->

        it 'trigger events for all stored messages', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          @messagesList.trigger('test', 42)
          @spy.should.be.calledWith(messageA, 42)
          spyB.should.be.calledWith(messageB, 42)

      describe '#on(event, callback, [options])', ->

        it 'listen to stored messages event', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          message.trigger('trololo', 42)
          @spy.should.be.calledWith(message, 42)

        it 'ignores hidden messages', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          messageA.trigger('hide')
          @messagesList.trigger('test', 42)
          @spy.should.not.be.called
          spyB.should.be.calledWith(messageB, 42)

        it 'allow to specify when hidden messages should be trigerred', ->
          spyB = sinon.spy()
          messageA = @messagesList.store(new Noted.Message())
          messageB = @messagesList.store(new Noted.Message())
          messageA.on('test', @spy)
          messageB.on('test', spyB)
          messageA.trigger('hide')
          @messagesList.trigger(hidden: true, 'test', 42)
          @spy.should.be.calledWith(messageA, 42)
          spyB.should.be.calledWith(messageB, 42)

      describe '#off([event], [callback])', ->

        it 'stop listening stored messages', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.off('trololo', @spy)
          message.trigger('trololo', 42)
          @spy.should.not.be.called

        it 'stop listening stored messages by event', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.off('trololo')
          message.trigger('trololo', 42)
          @spy.should.not.be.called

        it 'stop listening all events', ->
          message = new Noted.Message()
          @messagesList.store(message)
          @messagesList.on('trololo', @spy)
          @messagesList.on('test', @spy)
          @messagesList.off()
          message.trigger('trololo')
          message.trigger('test')
          @spy.should.not.be.called

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
          stub.should.be.calledWith('qwerty', 1)

          stub.restore()

        it 'returns message instance', ->
          message = @emitter.emit('test', 42)
          message.getBody().should.eq 42
          message.should.be.instanceOf Noted.Message

        it 'passes options to broker', ->
          spy = sinon.stub(@broker, 'publish')
          options = { a: 1, b: 2 }
          @emitter.emit('test', 42, options)
          spy.should.be.calledWith('test', 42, options)

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

        it 'can listen to emitted messages before listen is called', ->
          @broker.publish('some_message')
          @receiver.listen('some_message', @spy, delayed: true)
          @spy.should.be.called

        it 'can listen to emitted and undelivered messages before listen is called', ->
          spyB = sinon.spy()
          message = @broker.publish('some_message', 34)
          @receiver.listen('some_message', spyB)
          @broker.publish('some_message')
          @receiver.listen('some_message', @spy, delayed: true, undelivered: true)
          @spy.should.be.calledOnce
          @spy.should.be.calledWith(message)

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