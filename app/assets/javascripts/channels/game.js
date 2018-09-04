function conversationPage(player_id, conversation_id){
  console.log("Running conversation", player_id)
  var chat = $('#messages');

  App.chat = App.cable.subscriptions.create(
    {
      channel: "GameChannel", 
      room: player_id
    },{
      connected: () => console.log("Connected!"),
      disconnected: () => console.log("Disconnected!"),
      received: (data) => {
        switch(data.type){
          case "msg":
            if(chat.length > 0 && data.conversation == conversation_id){
              add_chat_message(chat, data, player_id);
            }else{
              $("#nav").toggleClass("notification");
            }
            break;
          case "state":
            if(data.state == "running"){
              $("#game-state").html("");
            }else{
              $("#game-state").html("<h3>DISCONNECTED</h3>The game is now over.")
            }
            break;
          default:
            console.log("Received message of type", data.type)
        }
      }, 
      rejected: () => console.log("Rejected!")
    }
  );

  if(chat.length > 0){
    chat.scrollTop(chat.height);
    var form = $('#new-message');
    var form_body = $("#message-body");
    form.submit((e) => {
      var msg = form_body.val();
      var scope = this;
      if(msg.length > 0){
        App.chat.perform('send_message', {contents: msg, conversation_id, player_id});
      }
      form_body.val("");

      e.preventDefault();
      return false;
    });
  }

  return App.chat;
}

function playerPage(player_id){
  App.chat = App.cable.subscriptions.create(
    {
      channel: "GameChannel", 
      room: player_id
    },{
      connected: () => console.log("Connected!"),
      disconnected: () => console.log("Disconnected!"),
      received: (data) => {
        switch(data.type){
          case "msg":
            var tab = $("#conversations-" + player_id + " #conversation-" + data.conversation)
            if(tab.length > 0){
              tab.toggleClass("unseen", true);
            }else{
              // This doesn't work in one specific case: Adding HRN tabs when it initiates the conversation
              // In all other cases, a tab will only be added when someone is sending you a message
              // So we can use message reciepient to label the tab
              // But not in this case, cause the server is sending the HRN messages /as/ HRN. Weird.
              $("#conversations-" + player_id).append("<div id='conversation-"+data.conversation+"' class='conversation unseen'><a href='/conversations/"+data.conversation+"'>"+data.number+"</a></div>")
            }
            break;
          case "state":
            if(data.state == "running"){
              $("#game-state").html("");
            }else{
              $("#game-state").html("<h3>DISCONNECTED</h3>The game is now over.")
            }
            break;
          default:
            console.log("Received message of type", data.type)
        }
        console.log("Received from channel:", data);
      }, 
      rejected: () => console.log("Rejected!")
    }
  );
}

// Adds the chat message into whichever place you want them to be.
function add_chat_message(chat, data, player_id){
  const extra = JSON.parse(data.extra);
  var message = data.message;
  if(extra.links){
    extra.links.forEach((link) => {
      message = message.replace(
        link.number,
        '<a rel="nofollow" data-method="post" href="/conversations?players[]='+link.id+'&players[]=' + player_id + '">' +link.number + "</a>"
      )
    });
  }

  var classes = 'message'
  if(data.player == player_id){
    classes += " from";
  }else{
    classes += " to";
    App.chat.perform('mark_read', {conversation_id: data.conversation, player_id});
  }

  chat.append("<div class='" + classes + "'><strong>" + data.number + "</strong><br>" + message + "</div>");
  chat.scrollTop(chat.height);

  $("#conversation-" + data.conversation).toggleClass("unseen", false);
}