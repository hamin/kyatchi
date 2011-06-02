
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
    mount: '/kyatchi',
    timeout: 45
});

// Mails server

smtp.createServer(function(connection) {
    connection.on('DATA', function(message) {
       var emailContent = '';
       console.log('Message from ' + message.sender)
       message.on('data', function(data) {
          console.log("DATA: " + data)
          emailContent += data;
       })
       message.on('end', function() {
          var email = { sender: connection.sender.address, recipients: connection.recipients, content: emailContent }
          console.log('EOT')
          // console.log('CONNECTION FOO')
          // console.log(connection)
          // console.log('EMAIL DATA')
          // console.log(emailContent)
          console.log('This is email object:')
          console.log(email.sender)
          bayeux.getClient().publish('/current_email', email);
          message.accept()
       })      
    })
}).listen(1025)

console.log("SMTP server running on port 1025")

// Routes

app.get('/', function(req, res){
  res.render('index', {
    title: 'Kyatchi - Catch the Mail!'
  });
});

// Only listen on $ node app.js

if (!module.parent) {
  bayeux.attach(app);
  app.listen(1080);
  console.log("Express server listening on port %d", app.address().port);
}
