Import_Service         = require '../../src/graph/Import-Service'
#Library_Import_Service = require '../../../src/services/import/Library-Import-Service'

describe '| services | import | Library-Import-Service |', ->

  importService  = null
  library_Import = null

  @timeout 5000

  before (done)->
    using new Import_Service(name: '_load_library_data'), ->
      importService = @
      library_Import = @.library_Import
      done()

  after ->
    #importService.cache.cacheFolder()
    #importService.cache.cacheFolder().folder_Delete_Recursive()

  it 'library_Json', (done)->
    library_Import.library (library)->
      library_Import.library_Json (library_Json)->
        library_Json.assert_Is_Object()
        using library_Json.guidanceExplorer.library.first()["$"], ->
          @.name.assert_Is library.id
          @.caption.assert_Is library.name
          done()

  it 'parse_Library_Json', (done)->
    library_Import.library (library)->
      library_Import.library_Json (library_Json)->
        library_Import.library_Json (json)->
          library_Import.parse_Library_Json (json), (_library)->
            using _library, ->
              @.id      .assert_Is library.id
              @.name    .assert_Is library.name
              @.folders .assert_Size_Is_Bigger_Than(0)
              @.articles.assert_Size_Is_Bigger_Than(0)
              @.views   .assert_Empty()
              done()

  it 'library', (done)->
    library_Import.library (library)->
      library.name.assert_Is_String()
      done()

  it 'article_Data', (done)->
    using library_Import, ->
      @.library (library)=>
        @.article_Data library.articles.first(), (article_Data)->
          article_Data.assert_Is_Object()
          done()