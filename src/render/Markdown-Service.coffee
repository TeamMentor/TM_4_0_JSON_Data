Markdown_It = require('markdown-it')

class Markdown_Service
  constructor: (options)->
    @markdownIt = Markdown_It()

  to_Html: (markdown, callback)=>
    html   = @markdownIt.render(markdown);
    try
      tokens = @markdownIt.parse(markdown)          #markdownIt.parse was throwing an exception when parsing wiki text
      callback(html, tokens) if callback
    catch
      callback(html) if callback
    html

module.exports = Markdown_Service