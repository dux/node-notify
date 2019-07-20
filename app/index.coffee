# Setup basic express server
path       = require('path')
bodyParser = require('body-parser')
express    = require("express")
app        = express()
server     = require("http").createServer(app)
io         = require('socket.io')(server)

app.use(bodyParser.json())
port = process.env.PORT or 8000
server.listen port, ->
  console.log "Server listening at port %d", port
  return

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
    res.type('json').send stringify(CHANNELS[@name])

  update: (@message) ->
    c = CHANNELS[@name]
    c.push(@message)
    c.shift() if c.length > 5

stringify = (data) -> JSON.stringify(data, null, 2)+"\n"

# core

# get channel messages, ping channel
app.get '/c/:channel', (req, res) ->
  res.set 'Access-Control-Allow-Origin': '*'

  History.send(res, req.params['channel'])

# send command to a channel
app.post '/c/:channel/:command', (req, res) ->
  res.set 'Access-Control-Allow-Origin': '*'

  name    = req.params['channel']
  object  = {
    func: req.params['command'],
    data: req.body
  }

  console.log("Channel #{name}: #{JSON.stringify(object.data)}")

  io.of("/c/#{name}").emit('msg', object);

  History.send(res, name, object.data)

# brodcast command to all channels
app.post '/b/:command', (req, res) ->
  res.set 'Access-Control-Allow-Origin': '*'

  command = req.params['command']
  object  = {
    func: command,
    data: req.body
  }

  keys = Object.keys(CHANNELS)

  for name in keys
    io.of("/c/#{name}").emit('msg', object);

  console.log("Broadcast to #{keys.length} clients: #{JSON.stringify(object.data)}")

  res.send stringify(object)

# other pages

app.get '/', (req, res) ->
  res.send('Node notify server by @dux')

app.get '/demo', (req, res) ->
  res.sendFile path.resolve('public/index.html')

app.get '/demo.js', (req, res) ->
  res.sendFile path.resolve('public/demo.js')

app.get '/*', (req, res) ->
  res.status(404).send('page not found')

