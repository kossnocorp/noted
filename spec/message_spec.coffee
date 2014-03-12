describe 'Noted.Message', ->

  beforeEach ->
    @spy = sinon.spy()
    @message = new Noted.Message('Test')

  describe 'body', ->

    describe '#getBody()', ->

      it 'returns body message', ->
        expect(@message.getBody()).to.be.eq 'Test'

    describe '#setBody()', ->

      it 'apply new body to message', ->
        @message.setBody('42 is the answer.')
        expect(@message.getBody()).to.be.eq '42 is the answer.'

  describe 'extended with Backbone.Events', ->

    it 'has Backbone.Events functions', ->
      fns = 'on off once listenTo stopListening listenToOnce'.split(/\s/)
      for fn in fns
        expect(@message[fn]).to.be.defined
        expect(@message[fn]).to.be.a 'function'

    it 'overries default Backbone.Events.trigger behaviour and pass self as first argument', ->
      @message.on('event', @spy)
      @message.trigger('event', 'test')
      expect(@spy).to.be.calledWith(@message, 'test')

  describe 'delivered state', ->

    describe '#isDelivered()', ->

      it 'marks as delivered by default', ->
        expect(@message.isDelivered()).to.be.false

      it 'returns actual state of notification', ->
        @message.setDelivered()
        expect(@message.isDelivered()).to.be.true

    describe '#setDelivered()', ->

      it 'sets delivered to true', ->
        @message.setDelivered()
        expect(@message.isDelivered()).to.be.true

      it 'sets delivered to passed argument', ->
        @message.setDelivered()
        @message.setDelivered(false)
        expect(@message.isDelivered()).to.be.false

  describe 'message has id', ->

    describe '#getId()', ->

      it 'returns id', ->
        expect(@message.getId()).to.not.exist

    describe '#setId(id)', ->

      it 'sets id', ->
        @message.setId(42)
        expect(@message.getId()).to.be.eq 42

  describe 'can be hidden', ->

    describe '#isHidden()', ->

      it 'returns message hidden state', ->
        expect(@message.isHidden()).to.be.false

    describe '#hide()', ->

      it 'set hidden state', ->
        @message.hide()
        expect(@message.isHidden()).to.be.true

      it 'can be called via "hide" event', ->
        @message.trigger('hide')
        expect(@message.isHidden()).to.be.true

      it 'should trigger hide event', ->
        @message.on('hide', @spy)
        @message.hide()
        expect(@spy).to.be.called

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
          expect(message.isHidden()).to.be.true
          expect(stub).to.be.calledWith('noted_trololo_hidden')

        it 'can store hidden state in cookies', ->
          message = new Noted.Message(42, 'trololo', store: 'cookie')
          message.hide()
          expect(cookie.set).to.be.calledWith('noted_trololo_hidden', true)

        it 'ignores hide if first argument is true', ->
          messageA = new Noted.Message(42, 'trololo', store: 'cookie')
          messageA.hide(true)
          messageB = new Noted.Message(42, 'trololo', store: 'cookie')
          messageB.trigger('hide', true)
          expect(cookie.set).to.not.be.called

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
          expect(message.isHidden()).to.be.true
          expect(stub).to.be.calledWith('noted_trololo_hidden')

        it 'can store hidden state in stores', ->
          message = new Noted.Message(42, 'trololo', store: 'store')
          message.hide()
          expect(store.set).to.be.calledWith('noted_trololo_hidden', true)
