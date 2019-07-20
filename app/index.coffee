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

sockets_cache   = {}
sockets_history = {}

socket_connect = (name) ->
  # io.of(req.path) MUST BE ON req.path !!! can't br generic name
  sockets_history[name] ||= {}
  sockets_cache[name] ||= io.of(name).on "connection", (socket) ->
    console.log "Channel init: #{name}"
    socket.on "all", (data) ->
      console.log [name, data]
      socket_emit(name, data)

socket_emit = (channel, object) ->
  # object['data']['_time'] = new Date().getTime()
  io.of(channel).emit('msg', object);

  c = sockets_history[channel][object.func] ||= []
  c.push(object.data)
  c.shift() if c.length > 5

format_response = (channel) ->
  JSON.stringify sockets_history[channel], null, 2

# get chennel messages
app.get '/c/:channel', (req, res) ->
  res.set 'Access-Control-Allow-Origin': '*'
  channel = "/c/#{req.params['channel']}"
  socket_connect(channel)
  res.type('json').send(format_response(channel))

# update channel and a group
app.post '/c/:channel/:group', (req, res) ->
  channel = "/c/#{req.params['channel']}"
  socket_connect(channel)
  socket_emit(channel, { func:req.params['group'], data:req.body })
  res.send(format_response(channel))

# other pages

app.get '/', (req, res) ->
  res.send('Node notify server by @dux')

app.get '/demo', (req, res) ->
  res.sendFile path.resolve('public/index.html')

app.get '/demo.js', (req, res) ->
  res.sendFile path.resolve('public/demo.js')

app.get '/*', (req, res) ->
  res.status(404).send('page not found')


  # if Object.keys(req.query).length > 0
  #   console.log ["qs:#{ns_name}", 'all', req.query]
  #   io.of(ns_name).emit('msg', req.query);


# io.of('/room').on "connection", (socket) ->
#   socket.on "all", (data) ->
#     #  sending to all clients, include sender
#     console.log data
#     io.of('/room').emit('msg', data);
#     # io.sockets.emit "msg", data


#   socket.on "others", (data) ->
#     # sending to all clients except sender
#     console.log data
#     socket.broadcast.emit "msg", data


#   socket.on "caller", (data) ->
#     console.log data
#     socket.broadcast.emit "msg", data
