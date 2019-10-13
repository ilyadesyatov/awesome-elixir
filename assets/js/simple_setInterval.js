// heroku no sleep
var http = require("https");
setInterval(function() {
    http.get("https://my-awesome-elixir.herokuapp.com");
}, 60000); // every 5 minutes (300000)