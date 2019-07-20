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

class History
  DATA = {}

  @send = (res, name, message) ->
    DATA[name] ||= []
    history = new History name
    history.update message if message
    history.send res

  constructor: (@name) ->
    DATA[@name] ||= []

  send: (res) ->
    res.type('json').send JSON.stringify(DATA[@name], null, 2)

  update: (message) ->
    c = DATA[@name]
    c.push(message)
    c.shift() if c.length > 5

#

# get channel messages
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

  io.of("/c/#{name}").emit('msg', object);

  History.send(res, name, object.data)


# other pages

app.get '/', (req, res) ->
  res.send('Node notify server by @dux')

app.get '/demo', (req, res) ->
  res.sendFile path.resolve('public/index.html')

app.get '/demo.js', (req, res) ->
  res.sendFile path.resolve('public/demo.js')

app.get '/*', (req, res) ->
  res.status(404).send('page not found')

