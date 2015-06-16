return
Article = require '../src/Article'

describe '| Article |',->

  #importService  = null
  article        = null
  article_Id     = null

  before (done)->
    article      = new Article()
    article.contentService.article_Ids (_article_Ids)->
      article_Id = _article_Ids.first()
      done()
    #importService = article.importService
    #importService.graph.openDb ->
    #  article.ids (articles_Ids)=>
    #    article_Id = articles_Ids.first()
     #   done()

  #after (done)->
  #  done();


  it 'constructor',->
    using new Article(),->
      #@.importService.assert_Is_Object()
      @.contentService.assert_Is_Object()
      @.assert_Is_Object()


  it 'ids', (done)->
    using article,->
      @.ids (articles_Ids)->
        articles_Ids.assert_Not_Empty()
        done()


  #it 'graph_Data', (done)->
  #  using article,->
  #    @.graph_Data article_Id, (data)=>
  #      data.is.assert_Is 'Article'
  #      data.id.assert_Is article_Id
  #      done()

  it 'article_Real_Path', (done)->
    using article, ->
      @.file_Path article_Id, (path)=>
        path.assert_File_Exists()
        done()

  it 'raw_Data', (done)->
    using article, ->
      @.raw_Data article_Id, (data)=>
        data.TeamMentor_Article.assert_Is_Object()
        data.TeamMentor_Article.Metadata.assert_Is_Object()
        data.TeamMentor_Article.Content.assert_Is_Object()
        data.TeamMentor_Article.Metadata.first().Id.first().assert_Contains article_Id.split('-').last()
        done()

  it 'raw_Content', (done)->
    using article, ->
      @.raw_Content article_Id, (data)=>
        data.assert_Is_String()
        done()

  it 'content_Type', (done)->
    using article, ->
      @.content_Type article_Id, (type)=>
        type.assert_Is_String()
        done()

  it 'html', (done)->
    using article, ->
      @.html article_Id, (html)=>
        html.assert_Contains(['<h2>','</h2>','<p>'])
        done()