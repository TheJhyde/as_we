$(document).ready(function(){
  var chat = $('#messages');

  if(chat.length > 0){
    var form = $('#new-message');
    var form_body = $("#message-body");

    App.chat = App.cable.subscriptions.create(
      {channel: "ChatChannel", room: "Conversation_" + conversation_id},
      {
        connected: () => console.log("Connected!"),
        disconnected: () => console.log("Disconnected!"),
        received: (data) => {
          console.log(data);
          const extra = JSON.parse(data.extra);
          var message = data.message;
          if(extra.links){
            extra.links.forEach((link) => {
              message = message.replace(
                link.number,
                '<a rel="nofollow" data-method="post" href="/conversations?player='+link.id+'">'+link.number+"</a>"
              )
            });
          }
          chat.append("<li>" + data.number + ": " + message + "</li>");
        }, 
        rejected: () => console.log("Rejected!")
      }
    );

    form.submit((e) => {
      var msg = form_body.val();
      var scope = this;
      if(msg.length > 0){
        App.chat.perform('send_message', {contents: msg, conversation_id, from_id});
      }
      form_body.val("");
      e.preventDefault();
      return false;
    });
  }
})