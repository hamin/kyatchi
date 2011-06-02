
/**
 * Module dependencies.
 */

var express = require('express'),
    faye = require('faye'),
    smtp = require('smtp/lib/smtp');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});


// Faye

var bayeux = new faye.NodeAdapter({
    mount: '/kiyachi',
    timeout: 45
});

// Mails server


smtp.createServer(function(connection) {
    connection.on('DATA', function(message) {
       var email = '';
       console.log('Message from ' + message.sender)
       message.on('data', function(data) {
          console.log("DATA: " + data)
          email += data;
          // bayeux.getClient().publish('/messages', {text: data});
       })
       message.on('end', function() {
          console.log('EOT')
          console.log('EMAIL DATA')
          console.log(email)
          message.accept()
       })      
    })
}).listen(1025)

console.log("SMTP server running on port 1025")

// Routes

app.get('/', function(req, res){
  res.render('index', {
    title: 'Mail Catcher'
  });
});

// Only listen on $ node app.js

if (!module.parent) {
  bayeux.attach(app);
  app.listen(1080);
  console.log("Express server listening on port %d", app.address().port);
}
