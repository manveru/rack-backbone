(function() {
  var BackboneWebSocketSync, Socket, p;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  p = function() {
    var _ref;
    return (_ref = window.console) != null ? typeof _ref.debug === "function" ? _ref.debug.apply(_ref, arguments) : void 0 : void 0;
  };
  window.Rubyists || (window.Rubyists = {});
  Socket = (function() {
    function Socket(options) {
      this.options = options;
      this.webSocket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
      this.connected = false;
      this.frame = 0;
      this.callbacks = {};
      this.connect();
    }
    Socket.prototype.connect = function() {
      return this.reconnector = setInterval((__bind(function() {
        return this.reconnect();
      }, this)), 1000);
    };
    Socket.prototype.reconnect = function() {
      if (this.connected) {
        return;
      }
      this.socket = new this.webSocket(this.options.server);
      this.socket.onmessage = __bind(function(messageEvent) {
        var body, callback, error, parsed;
        parsed = JSON.parse(messageEvent.data);
        p('parsed', parsed);
        if (callback = this.callbacks[parsed.frame]) {
          delete this.callbacks[parsed.frame];
          if (body = parsed.ok) {
            callback(body, true);
            return this.onmessage(body);
          } else if (error = parsed.error) {
            callback(error, false);
            return this.onmessage(error);
          }
        }
      }, this);
      this.socket.onerror = __bind(function() {
        return this.onerror.apply(this, arguments);
      }, this);
      this.socket.onopen = __bind(function() {
        this.connected = true;
        return this.onopen.apply(this, arguments);
      }, this);
      return this.socket.onclose = __bind(function() {
        this.connected = false;
        return this.onclose.apply(this, arguments);
      }, this);
    };
    Socket.prototype.onopen = function() {
      return p('open', this);
    };
    Socket.prototype.onmessage = function(body) {
      return p('message', body);
    };
    Socket.prototype.onclose = function() {
      return p('close', this);
    };
    Socket.prototype.onerror = function(error) {
      return p('error', error);
    };
    Socket.prototype.say = function(message, callback) {
      var packet;
      this.frame += 1;
      packet = {
        frame: this.frame,
        body: message
      };
      this.callbacks[this.frame] = callback;
      return this.socket.send(JSON.stringify(packet));
    };
    Socket.prototype.request = function(given) {
      return this.say(given.data, function(response, status) {
        if (status === true) {
          return typeof given.success === "function" ? given.success(response) : void 0;
        } else {
          return typeof given.error === "function" ? given.error(response) : void 0;
        }
      });
    };
    return Socket;
  })();
  window.Rubyists.Socket = Socket;
  BackboneWebSocketSync = function(method, model, options) {
    var data;
    data = {
      method: method,
      url: model.url,
      id: model.id,
      attributes: model.attributes
    };
    return Rubyists.syncSocket.request({
      data: data,
      success: options.success,
      error: options.error
    });
  };
  window.Rubyists.BackboneWebSocketSync = BackboneWebSocketSync;
}).call(this);
