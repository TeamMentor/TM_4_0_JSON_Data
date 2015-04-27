Wiki_Service = require '../../src/render/Wiki-Service'

describe '| services | render | Wiki-Service.test',->
  it 'constructor', ->
    using new Wiki_Service(), ->
      @.jsdom.assert_Is_Object()

  it 'to_Html', (done)->
    wiki_Text       = "== A title\n
                      \n
                      some text\n
                      \n
                      * a point"
    expected_Html   = "<h2>A title</h2><p> some text\n</p> <ul>\n<li> a point</li></ul>"

    using new Wiki_Service(), ->
      @.to_Html wiki_Text, (html)->
        html.assert_Is expected_Html
        done()


