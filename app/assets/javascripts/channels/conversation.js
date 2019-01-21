// This covers all the javascript that happens on the conversation page

function conversationPage(player_id, conversation_id, order_num){
  console.log("Running conversation", player_id)
  var chat = $('#messages');
  var last_order_num = order_num;

  if(chat.length > 0){
    //Scroll to the bottom 
    chat.scrollTop(chat[0].scrollHeight);
  }

  // Grabs the form, sets up sending the message to the backend
  var form = document.getElementById("new-message");
  var form_body = document.getElementById("message-body");

  form.addEventListener("submit", function(e){
    var msg = form_body.value;
    if(msg.length > 0){
      last_order_num++;
      App.chat.perform('send_message', {contents: msg, conversation_id, player_id, order_num: last_order_num})
    }
    form_body.value = "";

    e.preventDefault();
    e.stopPropagation();
    return false;
  });

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
              if(data.order_num > last_order_num){
                last_order_num = data.order_num;
              }
              add_chat_message(chat, data, player_id);
            }else{
              $("#nav").addClass("notification");
            }
            break;
          case "state":
            if(data.state == "end"){
              chat.append(
                "<div class='message system'>" +
                  "<div class='message-contents'>- SYSTEM OFFLINE -</div>" +
                "</div>"
              );
            }
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
  if(!extra.system_message && extra.links){
    extra.links.forEach((link) => {
      message = message.replace(
        link.number,
        '<a rel="nofollow" data-method="post" href="/conversations?players[]='+link.id+'&players[]=' + player_id + '">' +link.number + "</a>"
      )
    });
  }

  // the list of classes this message will have
  var classes = 'message'
  if(extra.system_message){
    classes += " system"
  }
  else if(data.player == player_id){
    classes += " from";
  }else{
    classes += " to";
    App.chat.perform('mark_read', {conversation_id: data.conversation, player_id});
  }

  // Adds the new chat message
  chat.append(
    "<div class='" + classes + "' data-order='" + data.order_num + "'>" +
      "<div class='chat-player-number'>" + data.number + "</div>" +
      "<div class='message-contents'>"+message+"</div>" +
    "</div>"
  );
  // I feel like sorting the whole thing every time is probably overkill
  $('message').sort((a, b) => {
    var aOrder = parseInt(a.getAttribute('data-order'));
    var bOrder = parseInt(b.getAttribute('data-order'));
    return (aOrder < bOrder) ? -1 : (bOrder < aOrder) ? 1 : 0;
  });

  // Scrolls to the new bottom of the box
  chat.scrollTop(chat[0].scrollHeight);
}