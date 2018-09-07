// This covers all the javascript that happens on the conversation page

function conversationPage(player_id, conversation_id){
  console.log("Running conversation", player_id)
  var chat = $('#messages');

  if(chat.length > 0){
    //Scroll to the bottom 
    chat.scrollTop(chat[0].scrollHeight);

    // Grabs the form, sets up sending the message to the backend
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

  // Connect to the channels
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
              $("#nav").addClass("notification");
            }
            break;
          case "state":
            // Haven't set anything up to happen on state changes on the conversation pages

            // if(data.state == "end"){
            //   $("#game-state").html("");
            // }else{
            //   $("#game-state").html("<h3>DISCONNECTED</h3>The game is now over.")
            // }
            break;
          default:
            console.log("Received message of type", data.type)
        }
      }, 
      rejected: () => console.log("Rejected!")
    }
  );

  return App.chat;
}

// Adds the chat message into whichever place you want them to be.
function add_chat_message(chat, data, player_id){
  // Extracts any extra elements to the message
  // Specifically, links to other chats
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

  // the list of classes this message will have
  var classes = 'message'
  if(data.player == player_id){
    classes += " from";
  }else{
    classes += " to";
    App.chat.perform('mark_read', {conversation_id: data.conversation, player_id});
  }

  // Appends the new chat message to the bottom of chats
  chat.append(
    "<div class='" + classes + "'>" +
      "<div class='chat-player-number'>" + data.number + "</div>" +
      "<div class='message-contents'>"+message+"</div>" +
    "</div>"
  );

  // Scrolls to the new bottom of the box
  chat.scrollTop(chat[0].scrollHeight);
}