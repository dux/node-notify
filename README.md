# Node notify server

Made as a replacement for Rails ActionCable, but can be used on any backend.

There is no need for a socket connection from a server, clean update interface via HTTP POST.

### Steps to make is work

* install
* run node notify server
* install client script and connect to chanell
* update node notify via curl

### What this notify can't to?

It can't conect to multiply channels. You can have only one connection server<->user.

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

#### Example 1

`curl -d 'JSON_DATA' -H "Content-Type: application/json" localhost:8000/c/CHANNEL/FUNCTION`

#### Example 2
`curl -d '{"data":"hello from server"}' -H "Content-Type: application/json" localhost:8000/c/usr-1/message`

#### Test script for constant ping

```while true; do curl -d '{"data":"'+`openssl rand -base64 32`+'"}' -H "Content-Type: application/json" localhost:8000/c/usr-1/message; sleep 2; done```

