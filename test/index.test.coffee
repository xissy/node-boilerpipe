should = require 'should'
fs = require 'fs'

Boilerpipe = require '../lib/index'


describe 'Boilerpipe', ->
  url = 'http://sports.news.nate.com/view/20130625n09440'
  html = fs.readFileSync("#{__dirname}/article.sample.html").toString()

  describe '.getText()', ->
    boilerpipe = new Boilerpipe
      extractor: Boilerpipe.Extractor.ArticleSentences
      url: url

    it 'should be done', (done) ->
      boilerpipe.getText (err, text) ->
        should.not.exist err
        should.exist text
        done()

  describe '.getHtml()', ->
    boilerpipe = new Boilerpipe
      extractor: Boilerpipe.Extractor.Article
      html: html

    it 'should be done', (done) ->
      boilerpipe.getHtml (err, html) ->
        should.not.exist err
        should.exist html
        done()

  describe '.getImages()', ->
    it 'should be done', (done) ->
      boilerpipe = new Boilerpipe
        extractor: Boilerpipe.Extractor.Article
        html: html
      ,
        (err) ->
          should.not.exist err
          
          boilerpipe.getImages (err, images) ->
            should.not.exist err
            should.exist images
            done()
