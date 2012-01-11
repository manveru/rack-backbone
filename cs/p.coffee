window.Rubyists ||= {}

p = ->
  window.console?.debug?(arguments ...)

Rubyists.p = p

class Socket
  constructor: (@options) ->
    @webSocket = if "MozWebSocket" of window then MozWebSocket else WebSocket
    @connected = false
    @frame = 0
    @callbacks = {}
    @connect()

  connect: () ->
    @reconnector = setInterval((=> @reconnect()), 1000)

  reconnect: () ->
    return if @connected
    @socket = new @webSocket(@options.server)
    @socket.onopen = => @onopen(arguments ...)
    @socket.onmessage = => @onmessage(arguments ...)
    @socket.onclose = => @onclose(arguments ...)
    @socket.onerror = => @onerror(arguments ...)

  onopen: ->
    @connected = true
    p open: this

  onmessage: (messageEvent) ->
    p message: messageEvent

  onclose: ->
    @connected = false
    p close: this

  onerror: (error) ->
    p error: [this, error]

  say: (message, callback) ->
    @frame += 1
    packet = {
      frame: @frame,
      message: message,
    }
    @callbacks[@frame] = callback
    @socket.send(JSON.stringify(packet))

window.Rubyists.Socket = Socket

backboneSyncSignature = (model) ->
  sig = {}
  sig.endPoint = "#{model.url}"
  if model.id?
    sig.endPoint = "#{model.url}/#{model.id}"
  sig.ctx = model.ctx if model.ctx
  sig

backboneSyncEvent = (operation, sig) ->
  if sig.ctx?
    "#{operation}:#{sig.endPoint}:#{sig.ctx}"
  else
    "#{operation}:#{sig.endPoint}"

backboneSync = (model, method, args, callback) ->
  sign = backboneSyncSignature(model)
  e = backboneSyncEvent(method, sign)
  args.method = method
  args.signature = sign
  Rubyists.syncSocket.say(args)
  Rubyists.syncSocket.once(e, callback)

BackboneWebSocketSync = (method, model, options) ->
  switch method
    when 'create'
      backboneSync model, method, item: model.attributes,
        (data) -> model.id = data.id
    when 'read'
      backboneSync model, method, null,
        (data) -> options.success(data)
    when 'update'
      backboneSync model, method, item: model.attributes
    when 'destroy'
      backboneSync model, method, item: model.attributes

window.Rubyists.BackboneWebSocketSync = BackboneWebSocketSync
