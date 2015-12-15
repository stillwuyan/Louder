function sendMessage() {
  var msg = document.getElementById("message");
  if (msg.innerHTML.length == 0) {  
      return;
  }
  var req = new XMLHttpRequest();
  req.onreadystatechange = function() {
      if ((req.readyState == 4) && (req.status == 200)) {
          var e = document.createElement("p");
          e.innerHTML = '<b style="color:blue">me:</b><br />' + req.responseText.replace(/\x20/g, '&nbsp;').replace(/\n/g, '<br />');
          document.getElementById("board").appendChild(e);
          msg.innerHTML = '';
      }
  }
  req.open("POST", "http://10.1.1.68:8008/index.html", true);
  req.setRequestHeader("Content-type", "text/plain");
  req.send(msg.innerHTML);
}
function hotKey() {
  var a=window.event.keyCode;
  if ((a == 13) && (event.altKey)) {
      sendMessage();
  }
}

document.onkeydown = hotKey;