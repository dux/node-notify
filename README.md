# Node notify server

Made as a replacement for Rails ActionCable, but can be used on any backend.

There is no need for a socket connection from a server, clean update interface via HTTP POST.

It can update specific channel or broadcast on all channels

### Steps to make is work

* install
* run node notify server
* install client script and connect to chanell
* update node notify via curl

### ENV

```coffeescript
CONFIG =
  # server port
  port:   process.env.PORT or 8000

  # server secret, if defined cant update channel from server without sending ?secret= param
  secret: process.env.SECRET || 'tajna'

  # "Access-Control-Allow-Origin" header param
  origin: process.env.ORIGIN '*'
```

### install

`npm install @dinoreic/node-notify`

### run server

`npx node-notify`


### app javascript  - connect to server

```coffeescript
class NodeNotify
  constructor: (@server) ->
    @subs = {}

    unless window.io
      $.getScript "#{@server}/socket.io/socket.io.js"

  sub: (name, func) =>
    @subs[name] = (data) =>
      return unless @socket
      func data

  connect: (func) ->
    channel = func()

    if channel && window.io
      url = "#{@server}/c/#{channel}"
      $.get url, (response) =>
        @socket = io.connect(url)
        @socket.on 'msg', (response) =>
          if c = @subs[response.func]
            c response.data
    else
      setTimeout =>
        @connect(func)
      , 200


$ ->
  notify = new NodeNotify 'http://localhost:8000'

  # respond to
  notify.sub 'message', (data) ->
    Info.ok data.data

  # connect if we have user id
  notify.connect ->
    return unless window.app
    return unless window.app.user
    window.app.user.uid
```

### Send message to node-notify via curl

`curl -d 'JSON_DATA' -H "Content-Type: application/json" localhost:8000/c/CHANNEL/FUNCTION`


#### Example: send to specific channel named "usr-1"
`curl -d '{"data":"hi from node notify server"}' -H "Content-Type: application/json" localhost:8000/c/usr-1/message`


#### Example: boradcast the same message to all connected clients
`curl -d '{"data":"hi from node notify server"}' -H "Content-Type: application/json" localhost:8000/b/message`


#### Test script for constant ping

```
  while true; do curl -d '{"data":"'+`openssl rand -base64 32`+'"}' -H "Content-Type: application/json" localhost:8000/c/usr-1/message; sleep 1; done

  while true; do curl -d '{"data":"'+`openssl rand -base64 32`+'"}' -H "Content-Type: application/json" localhost:8000/b/message; sleep 1; done
```

