Search_Artifacts_Service = require '../src/Search-Artifacts-Service'
Content_Service          = require '../src/Content-Service'

describe '| Search-Artifacts-Service |', ->
  search_Artifacts = null
  content_Service  = null
  article_Ids      = null

  before (done)->
    search_Artifacts = new Search_Artifacts_Service()
    using new Content_Service(), ->
      content_Service = @
      article_Ids = @.article_Ids()
      done()

  after (done)->
    done()

  it 'constructor',->
    search_Artifacts.constructor.name.assert_Is 'Search_Artifacts_Service'

  xit 'batch_Parse_All_Articles', (done)->
    @.timeout 0
    search_Artifacts.batch_Parse_All_Articles (results)->
      results.assert_Size_Is_Bigger_Than 100
      done()

  xit 'parse_Article', (done)->
    article_Id = article_Ids.first()
    search_Artifacts.parse_Article article_Id, (data)->
      data.id      .assert_Is article_Id
      data.checksum.assert_Is_String()
      data.words.keys().assert_Is_Bigger_Than 50
      data.tags .keys().assert_Is_Bigger_Than 1
      data.links       .assert_Is_Bigger_Than 0
      done()


  xit 'parse_Article_Html', (done)->
    article_Id = article_Ids.first() #[200.random()]  'article-9e203d1b630f'
    search_Artifacts.parse_Article_Html article_Id, (data)->
      data.id      .assert_Is article_Id
      data.checksum.assert_Is_String()
      data.words.keys().assert_Is_Bigger_Than 50
      data.tags .keys().assert_Is_Bigger_Than 1
      data.links       .assert_Is_Bigger_Than 0
      done()

  it 'parse_Articles', (done)->
    @.timeout 60000
    size = -1
    console.time 'parse_Articles'
    article_Ids = article_Ids.take(size).take(100)
    search_Artifacts.parse_Articles article_Ids, (results)->
      console.timeEnd 'parse_Articles'
      for item in results
        if item
          item.id.assert_Is_String()
      done()

  xit 'raw_Articles_Html', (done)->
    @.timeout 20000
    search_Artifacts.raw_Articles_Html (data)->
      data.assert_Not_Empty()
      done()

  xit 'create_Search_Mappings', (done)->
    @.timeout 0
    search_Artifacts.create_Search_Mappings ->
      done()
