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
            if(tab.length == 0){
              $("#conversations-" + player_id).append(
                "<a href='/conversations/"+data.conversation+"?from="+player_id+"'>" + 
                  "<div id='conversation-"+data.conversation+"' class='conversation unseen'>" +
                    data.tab + 
                  "</div>" + 
                "</a>"
              );
            }else if(data.player != player_id){
              // Don't trigger the unseen notification if the message is from this player
              // Only really relevant for HRN
              tab.toggleClass("unseen", true);
            }
            break;
          case "state":
            if(data.state == "running"){
              $("#game-state").html("<h3 class='fade'>Connected!</h3>");
              setTimeout(() => $("#game-state").html(""), 3000)
            }else{
              $("#game-state").html("<h3>DISCONNECTED</h3>The game is now over.")
            }
            break;
          default:
            console.log("Received message of unknown type", data)
        }
        console.log("REceived message", data);
      }, 
      rejected: () => console.log("Rejected!")
    }
  );
}