async = require 'async'
java = require 'java'

java.classpath.push "#{__dirname}/../jar/nekohtml-1.9.13.jar"
java.classpath.push "#{__dirname}/../jar/xerces-2.9.1.jar"
java.classpath.push "#{__dirname}/../jar/boilerpipe-core-1.2.0-xissy.jar"


HTMLFetcher = java.import 'de.l3s.boilerpipe.sax.HTMLFetcher'
InputSource = java.import 'org.xml.sax.InputSource'
StringReader = java.import 'java.io.StringReader'
BoilerpipeSAXInput = java.import 'de.l3s.boilerpipe.sax.BoilerpipeSAXInput'

ArticleExtractor = java.import 'de.l3s.boilerpipe.extractors.ArticleExtractor'
ArticleSentencesExtractor = java.import 'de.l3s.boilerpipe.extractors.ArticleSentencesExtractor'
CanolaExtractor = java.import 'de.l3s.boilerpipe.extractors.CanolaExtractor'
DefaultExtractor = java.import 'de.l3s.boilerpipe.extractors.DefaultExtractor'
KeepEverythingExtractor = java.import 'de.l3s.boilerpipe.extractors.KeepEverythingExtractor'
KeepEverythingWithMinKWordsExtractor = java.import 'de.l3s.boilerpipe.extractors.KeepEverythingWithMinKWordsExtractor'
LargestContentExtractor = java.import 'de.l3s.boilerpipe.extractors.LargestContentExtractor'
NumWordsRulesExtractor = java.import 'de.l3s.boilerpipe.extractors.NumWordsRulesExtractor'

HTMLHighlighter = java.import 'de.l3s.boilerpipe.sax.HTMLHighlighter'

ImageExtractor = java.import 'de.l3s.boilerpipe.sax.ImageExtractor'



class Boilerpipe
  @Extractor:
    Article: ArticleExtractor.INSTANCE
    ArticleSentences: ArticleSentencesExtractor.INSTANCE
    Canola: CanolaExtractor.INSTANCE
    Default: DefaultExtractor.INSTANCE
    KeepEverything: KeepEverythingExtractor.INSTANCE
    KeepEverythingWithMinKWords: KeepEverythingWithMinKWordsExtractor.INSTANCE
    LargestContent: LargestContentExtractor.INSTANCE
    NumWordsRules: NumWordsRulesExtractor.INSTANCE


  constructor: (params, callback) ->
    for k, v of params
      @[k] = v

    @extractor = Boilerpipe.Extractor.Default  if not @extractor?
    @isProcessed = false  if not @isProcessed?

    if callback?
      @process callback


  process: (callback) ->
    return callback new Error 'No URL or HTML provided'  if not @url and not @html

    async.waterfall [
      # url or html to inputSource.
      (callback) =>
        # url?
        if @url?
          async.waterfall [
            (callback) =>
              java.newInstance 'java.net.URL', @url, callback
          ,
            (urlObject, callback) =>
              HTMLFetcher.fetch urlObject, callback
          ,
            (htmlDocument, callback) =>
              @htmlDocument = htmlDocument
              htmlDocument.toInputSource callback
          ]
          ,
            callback

        # or html?
        else
          async.waterfall [
            (callback) =>
              java.newInstance 'java.io.StringReader', @html, callback
          ,
            (stringReader, callback) =>
              java.newInstance 'org.xml.sax.InputSource', stringReader, callback
          ]
          ,
            callback
    ,
      # inputSource to textDocument.
      (inputSource, callback) =>
        async.waterfall [
          (callback) =>
            java.newInstance 'de.l3s.boilerpipe.sax.BoilerpipeSAXInput', inputSource, callback
        ,
          (saxInput, callback) =>
            saxInput.getTextDocument callback
        ]
        , 
          callback
    ]
    ,
      # extract.
      (err, textDocument) =>
        @textDocument = textDocument
        @isProcessed = true
        @extractor.process textDocument, callback


  setUrl: (url, callback) ->
    @url = url
    @html = null
    @isProcessed = false

    if callback?
      @process callback
      
    @


  setHtml: (html, callback) ->
    @url = null
    @html = html
    @isProcessed = false

    if callback?
      @process callback

    @


  checkIsProcessed: (callback) ->
    if not @isProcessed
      @process callback
    else
      callback null


  getText: (callback) ->
    @checkIsProcessed (err) =>
      return callback err  if err?

      @textDocument.getContent callback


  getHtml: (callback) ->
    @checkIsProcessed (err) =>
      return callback err  if err?
    
      async.waterfall [
        (callback) =>
          HTMLHighlighter.newExtractingInstance callback
      ,
        (highlighter, callback) =>
          if @html?
            html = @html
          if @url?
            html = @htmlDocument.toInputSourceSync()

          highlighter.process @textDocument, html, callback
      ]
      ,
        callback


  getImages: (callback) ->
    @checkIsProcessed (err) =>
      return callback err  if err?

      if @html?
        html = @html
      if @url?
        html = @htmlDocument.toInputSourceSync()

      ImageExtractor.INSTANCE.process @textDocument, html, (err, imageJavaObjects) =>
        return callback err  if err?

        convertImageJavaObjectsToJs imageJavaObjects, callback



convertImageJavaObjectsToJs = (imageObjects, callback) ->
  return callback err  if err?

  imageObjects.size (err, size) ->
    return callback err  if err?
    return callback null, []  if size is 0

    async.map [0...size]
    ,
      (i, callback) ->
        imageObjects.get i, (err, imageObject) ->
          return callback err  if err?

          async.parallel
            src: (callback) ->
              imageObject.getSrc callback
            width: (callback) ->
              imageObject.getWidth (err, width) ->
                width = Number width  if width?
                callback err, width
            height: (callback) ->
              imageObject.getHeight (err, height) ->
                height = Number height  if height?
                callback err, height
            alt: (callback) ->
              imageObject.getAlt callback
            area: (callback) ->
              imageObject.getArea callback
          ,
            callback
    ,
      callback



module.exports = Boilerpipe
