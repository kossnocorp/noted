(function() {
  var Events, Noted, extendWithEvents,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Events = typeof window !== "undefined" && window !== null ? window.Backbone.Events : require('backbone').Events;

  extendWithEvents = function(obj) {
    var prop, value, _results;
    _results = [];
    for (prop in Events) {
      value = Events[prop];
      _results.push(obj[prop] = value);
    }
    return _results;
  };

  Noted = {};

  Noted.Message = (function() {
    function Message(body, id, options) {
      if (body == null) {
        body = '';
      }
      if (id == null) {
        id = void 0;
      }
      this.options = options != null ? options : {};
      this._hidden = this._isHidden(id);
      this.setBody(body);
      this.setId(id);
      this.listenTo(this, 'hide', this._hide);
    }

    Message.prototype.getBody = function() {
      return this.body;
    };

    Message.prototype.setBody = function(body) {
      this.body = body;
    };

    Message.prototype.delivered = false;

    Message.prototype.isDelivered = function() {
      return this.delivered;
    };

    Message.prototype.setDelivered = function(delivered) {
      this.delivered = delivered != null ? delivered : true;
    };

    Message.prototype.getId = function() {
      return this._id;
    };

    Message.prototype.setId = function(_id) {
      this._id = _id;
    };

    Message.prototype.isHidden = function() {
      return this._hidden;
    };

    Message.prototype.hide = function(doNotStore) {
      return this.trigger('hide', doNotStore);
    };

    Message.prototype._hide = function(message, doNotStore) {
      if (doNotStore == null) {
        doNotStore = false;
      }
      this._hidden = true;
      if (doNotStore) {
        return;
      }
      if (this.options.store === 'cookie' && (typeof cookie !== "undefined" && cookie !== null)) {
        return cookie.set("noted_" + (this.getId()) + "_hidden", true);
      } else if (this.options.store === 'store' && (typeof store !== "undefined" && store !== null ? store.enabled : void 0)) {
        return store.set("noted_" + (this.getId()) + "_hidden", true);
      }
    };

    Message.prototype._isHidden = function(id) {
      var hiddenKey, storage;
      if (id && (storage = this._storage())) {
        hiddenKey = "noted_" + id + "_hidden";
        return storage.get(hiddenKey) || false;
      } else {
        return false;
      }
    };

    Message.prototype._storage = function() {
      if (this.options.store === 'cookie' && (typeof cookie !== "undefined" && cookie !== null)) {
        return cookie;
      } else if (this.options.store === 'store' && (typeof store !== "undefined" && store !== null ? store.enabled : void 0)) {
        return store;
      } else {
        return null;
      }
    };

    return Message;

  })();

  extendWithEvents(Noted.Message.prototype);

  Noted.Message.prototype.trigger = function() {
    var args, event, _ref;
    event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return (_ref = Events.trigger).call.apply(_ref, [this, event, this].concat(__slice.call(args)));
  };

  Noted.Event = (function() {
    function Event(group, name) {
      this.group = group;
      this.name = name;
      this._messages = [];
    }

    Event.prototype.getName = function() {
      return this.name;
    };

    Event.prototype.getMessages = function() {
      return this._messages;
    };

    Event.prototype.add = function(message) {
      return this._messages.push(message);
    };

    Event.prototype.getGroup = function() {
      return this.group;
    };

    Event.prototype.setGroup = function(group) {
      this.group = group;
    };

    return Event;

  })();

  extendWithEvents(Noted.Event.prototype);

  Noted.EventGroup = (function() {
    function EventGroup(name) {
      this.name = name;
      this._eventObjs = {};
    }

    EventGroup.prototype.getName = function() {
      return this.name;
    };

    EventGroup.prototype.add = function(event) {
      if (event instanceof Noted.Event) {
        this._eventObjs[event.getName()] = event;
        event.setGroup(this);
        return event;
      } else {
        return this._eventObjs[event] = new Noted.Event(this, event);
      }
    };

    EventGroup.prototype.all = function() {
      var event, name, _ref, _results;
      _ref = this._eventObjs;
      _results = [];
      for (name in _ref) {
        event = _ref[name];
        _results.push(event);
      }
      return _results;
    };

    EventGroup.prototype.get = function(name) {
      return this._eventObjs[name];
    };

    EventGroup.prototype.remove = function(event) {
      var name;
      name = event instanceof Noted.Event ? event.name : event;
      return delete this._eventObjs[name];
    };

    return EventGroup;

  })();

  extendWithEvents(Noted.EventGroup.prototype);

  Noted.Broker = (function() {
    var MESSAGE_PATTERN;

    MESSAGE_PATTERN = /(?:(.+):|)([^#]*)(?:#(.+)|)/;

    function Broker() {
      this._eventGroups = {};
    }

    Broker.prototype.subscribe = function(message, callback, context, options) {
      var event, eventGroups, group, name, setDelivered, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      if (options == null) {
        options = {};
      }
      event = this.get(message);
      setDelivered = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        message = typeof args[0] === 'string' ? args[1] : args[0];
        message.setDelivered();
        return callback.apply(this, args);
      };
      setDelivered._callback = callback;
      if (options.delayed) {
        if (event.getName() === 'all') {
          eventGroups = [event.getGroup()] || this._eventGroups;
          for (name in eventGroups) {
            if (!__hasProp.call(eventGroups, name)) continue;
            group = eventGroups[name];
            _ref = group.all();
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              event = _ref[_i];
              _ref1 = event.getMessages();
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                message = _ref1[_j];
                if ((!options.undelivered || !message.isDelivered()) && !message.isHidden()) {
                  setDelivered.call(context, event.getName(), message);
                }
              }
            }
          }
        } else {
          _ref2 = event.getMessages();
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            message = _ref2[_k];
            if ((!options.undelivered || !message.isDelivered()) && !message.isHidden()) {
              setDelivered.call(context, message);
            }
          }
        }
      }
      return event.getGroup().on(event.getName(), setDelivered, context);
    };

    Broker.prototype.publish = function(message, body, options) {
      var event, hideFn, id;
      if (options == null) {
        options = {};
      }
      id = this.parse(message)[2];
      event = this.get(message);
      message = new Noted.Message(body, id, options);
      event.add(message);
      if (!message.isHidden()) {
        event.getGroup().trigger(event.getName(), message);
      }
      if (options.hideAfter) {
        hideFn = function() {
          return message.hide(options.storeHide ? !options.storeHide : void 0);
        };
        setTimeout(hideFn, options.hideAfter);
      }
      return message;
    };

    Broker.prototype.unsubscribe = function(message, callback, context) {
      var event, group, name, _ref, _results;
      if (message) {
        event = this.get(message);
        return event.getGroup().off(event.getName(), callback, context);
      } else {
        _ref = this._eventGroups;
        _results = [];
        for (name in _ref) {
          group = _ref[name];
          _results.push(group.off(null, callback, context));
        }
        return _results;
      }
    };

    Broker.prototype.get = function(message) {
      var eventName, group, groupName, id, _base, _ref;
      _ref = this.parse(message), groupName = _ref[0], eventName = _ref[1], id = _ref[2];
      group = (_base = this._eventGroups)[groupName] || (_base[groupName] = new Noted.EventGroup(groupName));
      return group.get(eventName) || group.add(eventName);
    };

    Broker.prototype.parse = function(message) {
      var eventName, groupName, id, _ref;
      _ref = message.match(MESSAGE_PATTERN).slice(1), groupName = _ref[0], eventName = _ref[1], id = _ref[2];
      return [groupName, eventName || 'all', id];
    };

    return Broker;

  })();

  Noted.MessagesList = (function() {
    function MessagesList(broker, context) {
      this._messages = [];
      this._events = {};
      extendWithEvents(this._events);
      this.setBroker(broker);
      this.setContext(context);
    }

    MessagesList.prototype.getBroker = function() {
      return this.broker;
    };

    MessagesList.prototype.setBroker = function(broker) {
      this.broker = broker;
    };

    MessagesList.prototype.getContext = function() {
      return this.context;
    };

    MessagesList.prototype.setContext = function(context) {
      this.context = context;
    };

    MessagesList.prototype.getMessages = function() {
      return this._messages;
    };

    MessagesList.prototype.store = function(message) {
      var retrigger;
      this._messages.push(message);
      retrigger = function() {
        var args, event, _ref;
        event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        return (_ref = this._events).trigger.apply(_ref, [event].concat(__slice.call(args)));
      };
      message.on('all', retrigger, this);
      return message;
    };

    MessagesList.prototype.trigger = function() {
      var args, event, maybeArgs, maybeEvent, maybeOptions, message, messages, options, result, _i, _len, _results;
      maybeOptions = arguments[0], maybeEvent = arguments[1], maybeArgs = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (typeof maybeOptions === 'string') {
        options = {};
        event = maybeOptions;
        args = [maybeEvent].concat(maybeArgs);
      } else {
        options = maybeOptions;
        event = maybeEvent;
        args = maybeArgs;
      }
      messages = (function() {
        var _i, _len, _ref;
        if (options.hidden) {
          return this._messages;
        } else {
          result = [];
          _ref = this._messages;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            message = _ref[_i];
            if (!message.isHidden()) {
              result.push(message);
            }
          }
          return result;
        }
      }).call(this);
      _results = [];
      for (_i = 0, _len = messages.length; _i < _len; _i++) {
        message = messages[_i];
        _results.push(message.trigger.apply(message, [event].concat(__slice.call(args))));
      }
      return _results;
    };

    MessagesList.prototype.on = function(event, callback) {
      return this._events.on(event, callback, this.context);
    };

    MessagesList.prototype.off = function(event, callback) {
      return this._events.off(event, callback);
    };

    return MessagesList;

  })();

  Noted.Emitter = (function(_super) {
    __extends(Emitter, _super);

    function Emitter() {
      return Emitter.__super__.constructor.apply(this, arguments);
    }

    Emitter.prototype.emit = function(message, body, options) {
      message = this.broker.publish(message, body, options);
      this._messages.push(message);
      return message;
    };

    return Emitter;

  })(Noted.MessagesList);

  Noted.Receiver = (function(_super) {
    __extends(Receiver, _super);

    function Receiver() {
      Receiver.__super__.constructor.apply(this, arguments);
    }

    Receiver.prototype.listen = function(message, callback, options) {
      var receiver, storeMessage;
      if (options == null) {
        options = {};
      }
      receiver = this;
      storeMessage = function() {
        var args, message;
        message = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        receiver._messages.push(message);
        return callback.apply(this, arguments);
      };
      callback._callback = storeMessage;
      return this.broker.subscribe(message, storeMessage, this.context, options);
    };

    Receiver.prototype.stop = function(message, callback) {
      return this.broker.unsubscribe(message, (callback != null ? callback._callback : void 0) || callback, this.context);
    };

    return Receiver;

  })(Noted.MessagesList);

  if (typeof window !== "undefined" && window !== null) {
    window.Noted = Noted;
  } else {
    module.exports = Noted;
  }

}).call(this);
