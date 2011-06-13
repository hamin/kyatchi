express = require 'express'
faye = require 'faye'
smtp = require 'smtp/lib/smtp'
em_parse = require './lib/parser_email'
growl = require('growl')

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
        content: {
            plain: parsedEmail.body[1].body[0].content,
            html: parsedEmail.body[2].body[0].content,
            source: parser.content
          }
      }
      
      osNotify parsedEmail.header.subject.value
      bayeux.getClient().publish '/current_email', currentEmail
      message.accept()
.listen(1025)

console.log "SMTP server running on port 1025"

# OS Notifications
osNotify = (messageTitle) ->
  if require('os').type() is "Darwin"
    growl.notify 'Kyatchi caught the mail!', {title: messageTitle, image: 'public/images/kyatchi-logo.png'}
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
  app.listen 1080
  console.log "Kyatchi web interface started on port %d", app.address().port
  