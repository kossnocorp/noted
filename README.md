# Noted.js - advanced events for JavaScript

[![Build Status](https://secure.travis-ci.org/kossnocorp/noted.png?branch=master)](http://travis-ci.org/kossnocorp/noted)

Noted.js designed for use with Backbone.js and depends on Backbone.Events.

## Key features

### Async!

Don't bother about initialization order.

``` js
broker.publish('event');

broker.subscribe('event', function (message) {
    console.log('w00t!');
}, null, { delayed: true });

//=> "w00t!"
```

### When you trigger event you get message object with own events

It give you ability to communicate in two ways through "model" of emitted message.

``` js
broker.subscribe('event', function (message) {
    message.on('message_event', function (message, text) {
        console.log(text);
    });
});

var message = broker.publish('event');

message.trigger('message_event', 'Hey!');

//=> "Hey!"
```

### More key features coming soon!

## Installation

TODO

## How big is Noted.js?

It's tiny.

```
Original size: 12763b or 12.46kb
Uglified size: 6265b (49% from original size)
GZipped size:  1932b or 1.89kb (15% from original size)
```

## Quick example

TODO

## Roadmap

See [milestones](https://github.com/kossnocorp/noted/issues/milestones).

## Changelog

See [releases](https://github.com/kossnocorp/noted/releases).

This project uses [Semantic Versioning](http://semver.org/) for release numbering.

## Contributors

Idea and code by [@kossnocorp](http://koss.nocorp.me).

Check out full list of [contributors](https://github.com/kossnocorp/noted/contributors).

Initially sponsored by [Toptal](http://toptal.com/).

## Additional info

This project is a member of the [OSS Manifesto](http://ossmanifesto.org).

## License

The MIT License

Copyright (c) 2013 Sasha Koss

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
