jscreole = require 'jscreole'
jsdom    = require('jsdom')

class Wiki_Service
  constructor: (options)->
    @jsdom    = jsdom.jsdom()
    @jscreole = new jscreole()
    @window   = @jsdom.parentWindow

  to_Html: (wiki_Text, callback)->
    div             = @window.document.createElement('div')
    global.document = @window.document
    @jscreole.parse(div, wiki_Text)
    delete global.document
    html = div.innerHTML
    callback(html) if callback
    html

module.exports = Wiki_Service