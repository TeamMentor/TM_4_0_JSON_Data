Markdown_Service = require '../../src/render/Markdown-Service'

describe '| render | Markdown-Service.test',->
  it 'constructor', ->
    using new Markdown_Service(), ->

  it 'to_Html', (done)->
    markdown        = "## A title\n
                      \n
                      some text\n
                      \n
                      * a point"
    expected_Html   = "<h2>A title</h2>\n<p>some text</p>\n<ul>\n<li>a point</li>\n</ul>\n"

    using new Markdown_Service(), ->
      @.to_Html markdown, (html)->
        html.assert_Is expected_Html
        done()


