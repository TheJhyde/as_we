function hostChannel(game_id){
  App.chat = App.cable.subscriptions.create(
    {
      channel: "HostChannel", 
      room: game_id
    },{
      connected: () => console.log("Connected to Host!"),
      disconnected: () => console.log("Disconnected from Host!"),
      received: (data) => {
        console.log("Got some host data", data);
        $("#player-list").append("<li>"+data.number+"</li>")
        if(data.count == 5){
          $("#player-list").append("There are four players online and the game may begin.");
        }
      }, 
      rejected: () => console.log("Rejected!")
    }
  );

  return App.chat;
}