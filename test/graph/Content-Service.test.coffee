path            = require 'path'
async           = require 'async'
Content_Service = require '../../src/graph/Content-Service'

describe.only '| services | import | Content-Service |', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.options    .assert_Is {}
      #@.content_Folder .assert_Contains '.tmCache'
      @.current_Library.assert_Is 'Lib_UNO'


  it 'construtor (with params)',->
    options = { current_Library: 'efg'}
    using new Content_Service(options), ->
      @.options    .assert_Is(options)
      @.current_Library.assert_Is(options.current_Library )


  it 'library_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)->
        folder.assert_Folder_Exists()
              .assert_Contains('Lib_UNO')
        done()

  it 'library_Json_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.library_Json_Folder (json_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          json_Folder   .assert_Is(library_Folder.append("-json#{path.sep}Library"))
          json_Folder.assert_Folder_Exists()
          done()

  it 'article_Data', (done)->
    using contentService,->
      check_File = (json_File, next)=>
        article_Id  = json_File.file_Name().remove('.json')
        @article_Data article_Id, (article_Data)->
          if (article_Data.TeamMentor_Article)
            using article_Data.TeamMentor_Article, ->
              @.assert_Is_Object()
              @.Metadata.assert_Is_Object()
              @.Content.assert_Is_Object()
          next()

      @.json_Files (json_Files)->
        async.each json_Files.take(10), check_File, done