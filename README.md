# Node notify server

Made as a replacement for Rails ActionCable, but can be used on any backend.

There is no need for a socket connection from a server, clean update interface via HTTP POST.

It can update specific channel or broadcast on all channels

### Steps to make is work

* install
* run node notify server
* install client script and connect to chanell
* update node notify via curl

### install

`npm install @dinoreic/node-notify`

### run server

`npx node-notify`


### app javascript  - connect to server

```coffeescript
window.node_notify_server = 'http://localhost:8000'

PubSub = ->
  @subs = {}

  @connect = (channel) ->
    $.getScript "#{window.node_notify_server}/socket.io/socket.io.js", =>
      url = "#{window.node_notify_server}/c/#{channel}"

      $.get url, (response) =>
        @socket = io.connect(url)
        @socket.on 'msg', (response) =>
          if c = @subs[response.func]
            c response.data

  @sub = (name, func) =>
    @subs[name] = (data) =>
      return unless @socket
      func data

  @

user_channel = new PubSub()
user_channel.connect 'usr-1'

#

user_channel.sub 'message', (data) ->
  Info.ok data.data

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

