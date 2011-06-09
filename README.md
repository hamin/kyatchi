# Kyatchi

![Kyatchi logo](https://github.com/hamin/kyatchi/raw/master/public/images/kyatchi-logo.png)

Kyatchi **_(キャッチ catch)_** is a light NodeJS port of [Mailcatcher][mailcatcher-github]. Kyatchi is written on top of the super simple Sinatra-like web framework for NodeJS, [ExpressJS][expressjs]. The server and client-side javascript is all written in Coffeescript.

Like [Mailcatcher][mailcatcher-github] Kyatchi runs a super simple SMTP server which catches any message sent to it to display in a web interface. Run Kyatchi, set your favorite app to deliver to smtp://127.0.0.1:1025 instead of your default SMTP server, then check out http://127.0.0.1:1080 to see the mail that's arrived so far. 

Kyatchi also sends new messages to the web interface through [WebSockets][websockets] **with failover support for ANY browser that doesn't support Websockets**. This is done through the power of the awesome and simple pub/sub library [Faye][faye].

<!-- ![Kyatchi screenshot]() -->

## Features

* Catches all mail and stores it for display.
* Shows HTML, Plain Text and Source version of messages, as applicable.
* Mail appears instantly **on any browser**.
* Runs as a daemon run in the background.
* Written super-simply in on top of [ExpressJS][expressjs] via Coffeescript, very easy to change.

## How

1. `npm install kyatchi`
2. `kyatchi`
3. Go to http://localhost:1080/
4. Send mail through smtp://localhost:1025

The source is simple and [available on GitHub][kyatchi-github].

### Rails

To set up your rails app, I recommend adding this to your `environment/development.rb`:

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { :host => "localhost", :port => 1025 }
    
### ANYTHING ELSE!

Doesn't matter what programming language/framework you're using. If it uses smtp to send messages, then Kyatchi will work for you!

## Caveats

* Email download needs work.

## TODO

* Fix Email download, currently line breaks aren't being persisted
* Add support for Attachments
* Add ability to specify smtp and web interface ports through command line interface
* Growl support.

## Thanks

I was surprised how quickly I was able to get Kyatchi up and running. We definitely have some very powerful tools at our fingertips right now. A big thanks to all of the authors/contributors of the whole stack used in Kyatchi. I would also like to thank the following people:

* [Samuel Cochran][sam] - Thanks for writing and open sourcing [Mailcatcher][mailcatcher-github]. It was definitely the inspiration I needed. (Hope you don't mind me borrowing your styling :) )
* [Aria Stewart][aria] - Thanks for your awesome and simple [SMTP library][smtp-lib]. And thanks for suggesting the name for this project :)
* [Leejay (Liangjie Xia)][leejay] - Thanks for helping me debug some of the smtp parsing
* [Drew Tempelmeyer][drew] - Thanks for the awesome logo!

## Donations

I started this project beacause I've been wanting to write something like this for a while, but I am doing this in my free time. If you are so inclined, buy me a cup of cofee, soda, or some nourishment by [donating via Amazon Payments](donate).

## License

Copyright (c) 2011 Haris Amin (aminharis7@gmail.com). Released under the MIT License, see [LICENSE][license] for details.

  [donate]: https://www.amazon.com
  [license]: https://github.com/hamin/kyatchi/blob/master/LICENSE
  [mailcatcher-github]: https://github.com/sj26/mailcatcher
  [websockets]: http://www.whatwg.org/specs/web-socket-protocol/
  [faye]: http://faye.jcoglan.com/
  [expressjs]: http://expressjs.com/
  [kyatchi-github]: http://github.com/hamin/kyatchi/
  [smtp-lib]: http://github.com/aredridel/node-smtp
  [sam]: https://github.com/sj26
  [aria]: https://github.com/aredridel
  [leejay]: https://github.com/ljxia
  [drew]: https://github.com/drewtempelmeyer

