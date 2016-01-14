function scrollToBottem() {
    var board = $("div#board");
    if (board[0].scrollHeight > board[0].clientHeight) {
        board[0].scrollTop = board[0].scrollHeight;
    }
}

function sendMessage() {
    var message = $("div#notepad #message");
    if (message.val().length == 0) {  
        return;
    }
    appendMessage("me", message.val());
    $.support.cors = true;    // For IE9.
    $.ajax({
        url: "http://10.1.1.68:8008/index",
        type: "POST",
        crossDomain: true,
        contentType: "application/json",
        data: JSON.stringify({name: $("div#header #user").text(), value: message.val()})
    });
    message.val('');
}

function getMessage() {
    $.support.cors = true;  // For IE9.
    $.ajax({
        url: "http://10.1.1.68:8008/index",
        type: "GET",
        cache: false,
        success: function(result) {
            appendMessage(result.name, result.value);
            getMessage();
        }
    });
}

function appendMessage(user, msg) {
    $("div#board").append('<b>' + user + ':</b><br />');
    $("div#board").append('<p>' + msg.replace(/\x20/g, '&nbsp;').replace(/\n/g, '<br />') + '</p>');
    scrollToBottem();    
}

function hotKey() {
    var key = window.event.keyCode;
    if ((key == 13) && (event.altKey)) {
        sendMessage();
    }
}

function changeName() {
    var input = $("div#header #user input");
    if (input.length > 0) {
        return;
    }
    var user = $("div#header #user");
    var name = user.text();
    user.text('');
    user.append("<input id=\"username\">");
    
    input = $("div#header #user input");
    input.val(name);
    input.select();
    input.focusout(function(){
        name = (input.val() == '' ? name : input.val());
        input.remove();
        user.text(name);
    });
}
$(document).ready(function(){
    $(document).keydown(hotKey);
    $("div#header #user").dblclick(changeName);
    getMessage();    
});
