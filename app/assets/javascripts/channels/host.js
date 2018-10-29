function hostChannel(game_id){
  App.chat = App.cable.subscriptions.create(
    {
      channel: "HostChannel", 
      room: game_id
    },{
      connected: () => console.log("Connected to Host!"),
      disconnected: () => console.log("Disconnected from Host!"),
      received: (data) => {
        console.log(data);
        switch(data.type){
          case 'new_player':
            $("#player-list").append("<li id='player-list-" + data.id +"'>"+data.number+"</li>")
            if(data.count == 6){
              $("#player-list").append("There are four players online and the game may begin.");
            }
            break;
          case 'player_leave':

            $("#player-list-" + data.id).append(" (LEFT)");
            break;
          default:
            console.log("Unknown type", data);
        }
        
      }, 
      rejected: () => console.log("Rejected!")
    }
  );

  return App.chat;
}