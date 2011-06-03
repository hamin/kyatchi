
/**
 * Module dependencies.
 */

var express = require('express'),
    faye = require('faye'),
    smtp = require('smtp/lib/smtp'),
    em_parse = require('./lib/parser_email');

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
       // var emailContent = '';
       var emailContent = [];
       console.log('Message from ' + message.sender)
       message.on('data', function(data) {
          // console.log("DATA: " + data)
          emailContent += data;
       })
       message.on('end', function() {
          console.log('EOT');
          parser = em_parse.parser_email();
          parser.setContent(emailContent);
          foo = parser.parseMail();
          console.log('=======');
          // console.log(foo.body[2].body);
          console.log(foo.body[2].body[0].content)
          
          var currentEmail = {
            from: foo.header.from.value, 
            to: foo.header.to.value, 
            subject: foo.header.subject.value, 
            created_at: foo.header.date.value,
            htmlContent: foo.body[2].body[0].content
            }
          // console.log('@@@@ OUR OBJECT @@@@');
          // console.log(currentEmail);
          bayeux.getClient().publish('/current_email', currentEmail);

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
