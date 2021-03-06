express = require 'express'
faye = require 'faye'
smtp = require 'smtp/lib/smtp'
em_parse = require './lib/parser_email'
growl = require 'growl'
libnotify = require 'libnotify'
optimist = require 'optimist'

argv = optimist.usage('Kyatchi - Catch the Mail!', {
  'web':{
    description: 'Web interface for viewing the incoming emails',
    required: false,
    default: 1080,
    short: 'w',
    alias: 'w'
  },
  'mail':{
    description: 'SMTP Mail Server for incoming emails',
    required: false,
    default: 1025,
    short: 'm',
    alias: 'm'
  },
  'silent':{
    description: 'Turns off OS notifications for incoming emails (Growl/LibNotify)',
    required: false,
    boolean: true,
    short: 's',
    alias: 's'
  }
}).argv


optimist.showHelp();

app = module.exports = express.createServer()

# Configuration

app.configure () ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.compiler( src: __dirname + '/public', dest: __dirname + '/public', enable: ['coffeescript'] )
  app.use express.static("#{__dirname}/public")
    
app.configure () -> app.use express.errorHandler({ dumpExceptions: true, showStack: true})

# Faye

bayeux = new faye.NodeAdapter mount: '/kyatchi', timeout: 45

# Mail server

smtp.createServer (connection) ->
  connection.on 'DATA', (message) ->
    emailContent = ''
    
    message.on 'data', (data) ->
      emailContent += data
    
    message.on 'end', () ->
      parser = em_parse.parser_email()
      parser.setContent emailContent
      parsedEmail = parser.parseMail()
      
      currentEmail = {
        from: parsedEmail.header.from.value, 
        to: parsedEmail.header.to.value, 
        subject: parsedEmail.header.subject.value, 
        created_at: parsedEmail.header.date.value,
        content: setMessageContent parsedEmail, parser
      }
      
      osNotify parsedEmail.header.subject.value unless argv.silent
      bayeux.getClient().publish '/current_email', currentEmail
      message.accept()
.listen(argv.mail)

console.log "SMTP server running on port #{argv.mail}"

# Handle Email body properly with respect to content-type
setMessageContent = (email, emailParser) ->
  if email.header['content-type'].value is ('multipart/alternative' or 'multipart/mixed')
    { plain: email.body[1].body[0].content, html: email.body[2].body[0].content, source: emailParser.content }
  else
    { plain: email.body[0].content, html: email.body[0].content, source: emailParser.content }
    
# OS Notifications
osNotify = (messageTitle) ->
  if require('os').type() is "Darwin"
    growl.notify 'Kyatchi caught the mail!', {title: messageTitle, image: 'public/images/kyatchi-logo.png'}
  else if require('os').type() is "Linux"
    libnotify.notify 'Kyatchi caught the mail!', {title: messageTitle, image: 'public/images/kyatchi-logo.png'}
  else
    console.log 'Growl or Libnotify were not found!'



# Routes

app.get '/', (req,res) -> res.render 'index', title: 'Kyatchi - Catch the Mail!'

app.post '/download/:id', (req,res) ->
  console.log req.body
  console.log req
  # email = req.query.email
  # email = "foobar is cool"
  
  res.send req.body.email, {"content-type": "message/rfc822"}, 200
  
# Only listen on $ node app.coffee
if !module.parent
  bayeux.attach app
  app.listen argv.web
  console.log "Kyatchi web interface started on port #{app.address().port} - http://#{app.address().address}:#{app.address().port}"
  