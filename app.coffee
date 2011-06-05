express = require 'express'
faye = require 'faye'
smtp = require 'smtp/lib/smtp'
em_parse = require './lib/parser_email'

app = module.exports = express.createServer()

# Configuration

app.configure () ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static("#{__dirname}/public")
    
app.configure () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true})

app.configure () ->
  app.use express.errorHandler()

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
      foo = parser.parseMail()
      
      currentEmail = {
        from: foo.header.from.value, 
        to: foo.header.to.value, 
        subject: foo.header.subject.value, 
        created_at: foo.header.date.value,
        content: {
            plain: foo.body[1].body[0].content,
            html: foo.body[2].body[0].content,
            source: emailContent
          }
      }
      
      bayeux.getClient().publish '/current_email', currentEmail
      
      message.accept()
.listen(1025)

console.log "SMTP server running on port 1025"

# Routes

app.get '/', (req,res) ->
  res.render 'index', title: 'Kyatchi - Catch the Mail!'
  
# Only listen on $ node app.coffee
if !module.parent
  bayeux.attach app
  app.listen 1080
  console.log "Express server listening on port %d", app.address().port
  