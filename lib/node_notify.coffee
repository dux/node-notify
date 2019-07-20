class window.NodeNotify
  constructor: (@server) ->
    @subs = {}

    unless window.io
      head   = document.getElementsByTagName('head')[0]
      script = document.createElement('script')
      script.src  = "#{@server}/socket.io/socket.io.js"
      head.appendChild(script);

  sub: (name, func) =>
    @subs[name] = (data) =>
      return unless @socket
      func data

  connect: (func) ->
    channel = func()

    if channel && window.io
      url = "#{@server}/c/#{channel}"
      @socket = io.connect(url)
      @socket.on 'msg', (response) =>
        if c = @subs[response.func]
          c response.data
    else
      setTimeout =>
        @connect(func)
      , 200

