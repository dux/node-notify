# Setup basic express server
path       = require('path')
bodyParser = require('body-parser')
express    = require("express")

#

require('dotenv').config()

CONFIG =
  port:   process.env.NODE_NOTIFY_PORT   || 8000
  secret: process.env.NODE_NOTIFY_SECRET
  origin: process.env.NODE_NOTIFY_ORIGIN || '*'

#

app    = express()
server = require("http").createServer(app)
io     = require('socket.io')(server)
app.use(bodyParser.json())
server.listen CONFIG.port, ->
  console.log "Server listening at port %d", CONFIG.port

#

CHANNELS = {}

class History
  @send = (res, name, message) ->
    CHANNELS[name] ||= []
    history = new History name
    history.update message if message
    history.send res

  constructor: (@name) ->
    CHANNELS[@name] ||= []

  send: (res) ->
    res.type('json').send App.stringify(CHANNELS[@name])

  update: (@message) ->
    c = CHANNELS[@name]
    c.push(@message)
    c.shift() if c.length > 5

App =
  stringify: (data) ->
    JSON.stringify(data, null, 2)+"\n"

  construct_object: (req, res) ->
    res.set 'Access-Control-Allow-Origin': CONFIG.origin

    object  =
      func: req.params['command'],
      data: req.body

    if secret = CONFIG.secret
      if !req.query.secret
        res.status(403).send({error:'Secret not defined'})
        return false

      else if req.query.secret != secret
        res.status(403).send({error:'Wrong secret'})
        return false

    object

# core

# get channel messages, ping channel
app.get '/c/:channel', (req, res) ->
  res.set 'Access-Control-Allow-Origin': '*'

  History.send(res, req.params['channel'])

# send command to a channel
app.post '/c/:channel/:command', (req, res) ->
  if object = App.construct_object(req, res)
    name = req.params['channel']
    console.log("Channel #{name}: #{JSON.stringify(object)}")
    io.of("/c/#{name}").emit('msg', object);
    History.send(res, name, object.data)

# brodcast command to all channels
app.post '/b/:command', (req, res) ->
  if object = App.construct_object(req, res)
    keys = Object.keys(CHANNELS)

    for name in keys
      io.of("/c/#{name}").emit('msg', object);

    console.log("Broadcast to #{keys.length} clients: #{JSON.stringify(object)}")

    res.send App.stringify(object)

# other pages

app.get '/', (req, res) ->
  res.send('Node notify server by @dux')

app.get '/demo', (req, res) ->
  res.sendFile path.resolve('public/index.html')

app.get '/demo.js', (req, res) ->
  res.sendFile path.resolve('public/demo.js')

app.get '/*', (req, res) ->
  res.status(404).send('page not found')

