# node-boilerpipe

A node.js wrapper for [Boilerpipe](https://code.google.com/p/boilerpipe/), an excellent Java library for boilerplate removal and fulltext extraction from HTML pages.


## Installation

node-boilerpipe depends on [Boilerpipe](https://code.google.com/p/boilerpipe/) v1.2.0 or higher.

WARNING: Don't forget to set JAVA variable referred to [node-java](https://github.com/nearinfinity/node-java).

Via [npm](https://npmjs.org):

    $ npm install boilerpipe
  

## Usage

### Load in the module
```javascript
  var Boilerpipe = require('boilerpipe');
```

### Create a new instance
The constructor takes a `extractor`, being one of the available boilerpipe extractor types:

  * DefaultExtractor
  * ArticleExtractor
  * ArticleSentencesExtractor
  * KeepEverythingExtractor
  * KeepEverythingWithMinKWordsExtractor
  * LargestContentExtractor
  * NumWordsRulesExtractor
  * CanolaExtractor

If no extractor is passed the `DefaultExtractor` will be used by default. Additional keyword arguments are either `html` for HTML text or `url`.
```javascript
  var boilerpipe = new Boilerpipe();

  var boilerpipe = new Boilerpipe({
    extractor: Boilerpipe.Extractor.Canola
  });

  var boilerpipe = new Boilerpipe({
    extractor: Boilerpipe.Extractor.Article,
    url: 'http://...'
  });

  var boilerpipe = new Boilerpipe({
    extractor: Boilerpipe.Extractor.ArticleSentences,
    html: '<html>...</html>'
  }, function(err) {
    ...
  });
```

### Set URL or HTML
If you set both URL and HTML then only URL will work for you. HTML will be ignored at this case.
```javascript
  boilerpipe.setUrl('http://...');

  boilerpipe.setHtml('<html>...</html>');
```

### Get text, html and images
```javascript
  boilerpipe.getText(function(err, text) {
    ...
  });

  boilerpipe.getHtml(function(err, html) {
    ...
  });

  boilerpipe.getImages(function(err, images) {
    ...
  });
```

## License

Released under the MIT License

Copyright (c) 2013 Taeho Kim <xissysnd@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/xissy/node-boilerpipe/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

