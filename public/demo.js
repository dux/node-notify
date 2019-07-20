// PubSub lib

PubSub = function (channel) {
  this.sub = {}
  url      = 'http://localhost:8000/c/'+(channel)
  me       = this

  $.get(url, function(response) {
    me.socket = io.connect(url);
    me.socket.on('msg', function(response) {
      console.log(response)
      var c;
      if ( ! me.socket ) return
      if (c = me.sub[response.func]) {
        c(response.data)
      }
    })
  });

  this.pub = function(func, data) {
    if (!this.socket ) { return; }
    me.socket.emit('all', { func:func, data:(data || {}) });
  };
}

// channel info
window.channel_id = location.href.split('?')[1] || 'root'

ch = new PubSub(window.channel_id)
ch.sub.mouse   = function (data) { $('#mouse').val(data.pos) },
ch.sub.chat    = function (data) { $('#chat_data')[0].value  += data.nick+": "+data.data+"\n" }
ch.sub.g_info  = function (data) { alert('yay'); $('#gobal_data')[0].value += data.message+"\n" }

// custom functions
function add_to_chat() {
  nick = $('#nick').val() || 'guest'
  data = $('#textdata').val();
  ch.pub('chat', { nick:nick, data:data })
}

// addd to global
function add_to_global() {
  data = $('#global_input').val() || 'undefined'
  $('#global_input').val('')
  ch.pub('g_info', { message: data })
}

$(document).mousemove(function(e){
  ch.pub('mouse', { pos:e.pageX+'-'+e.pageY })
})

