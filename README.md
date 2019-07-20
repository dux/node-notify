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

or

`yarn add @dinoreic/node-notify`

### run server

`npx node-notify`


### app javascript  - connect to server

```coffeescript
import NodeNotify from '@dinoreic/node-notify'

$ ->
  notify = new NodeNotify 'http://localhost:8000'

  # respond to
  notify.sub 'message', (data) ->
    alert data.data

  # connect if we have user id
  notify.connect -> window.user_uid

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

