function clock(start_time){
  setClock(start_time);
  setInterval(function(){
    setClock(start_time);
  }, 1000)
}

function setClock(start_time){
  $("#clock").html(millisToTime(Date.now() - start_time))
}

function millisToTime(millis){
  const mToS = 1000;
  const mToM = 60 * mToS;
  const mToH = 60 * mToM;
  var hours = Math.floor(millis / mToH);
  var remaining = millis - hours * mToH;
  var minutes = Math.floor(remaining / mToM);
  if(minutes == 60){
    hours++;
    minutes = 0;
  }
  remaining = remaining - minutes * mToM;
  var seconds = (remaining/mToS).toFixed(0);
  if(seconds == 60){
    minutes++;
    seconds = 0;
  }
  return "0" + hours + ":" + (minutes < 10 ? "0" : "" ) + minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
}