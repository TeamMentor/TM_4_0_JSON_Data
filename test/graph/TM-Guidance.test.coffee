return

TM_Guidance      = require '../../src/graph/TM-Guidance'
Import_Service   = require '../../src/graph/Import-Service'

describe '| graph | TM-Guidance.test', ->

  tmGuidance = null

  beforeEach ->
    options = { importService : new Import_Service(name: '_tm_uno_test') }
    tmGuidance  = new TM_Guidance options

  afterEach (done)->
    tmGuidance.importService.graph.deleteDb ->
        #tmGuidance.importService.cache.cacheFolder().folder_Delete_Recursive()
        done()

  it 'constructor',->
    TM_Guidance.assert_Is_Function()
    tmGuidance.importService.assert_Is_Object()
    #tm_uno.library_Name = 'Guidance'

  it 'setupDb', (done)->
    tm_uno = new TM_Guidance()

    using tmGuidance, ->
      @.setupDb ->
        @.library.assert_Is_Object()
        done();



  it 'create_Metadata_Global_Nodes', (done)->
    using tmGuidance, ->
      @.setupDb =>
        @.create_Metadata_Global_Nodes =>
          @.importService.graph.allData (data)->
            data.assert_Size_Is(12)
            done()

  it '(add library query)', (done)->
    using tmGuidance, ->
      @.setupDb =>
        @.importService.library_Import.library (library)=>
          @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Query', library.id, library.name, (library_Id)=>
            @.importService.graph.allData (data)->
              data.first() .object   .assert_Is_String()
              data.second().object   .assert_Is_String()
              data.third() .predicate.assert_Is('guid')
              done()

  it 'import_Articles',(done)->
    using tmGuidance, ->
      @.setupDb =>
        @.importService.library_Import.library (library)=>
          @.create_Metadata_Global_Nodes =>
            @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Query', library.id, library.name, (library_Id)=>
              @.import_Articles library.id, library.articles.take(1), =>
                @.importService.graph.allData (data)->
                  data.assert_Size_Is(36)
                  done()

  it 'load_Data (and save it)', (done)->
    @timeout 20000
    using tmGuidance, ()->
      @.load_Data ()=>
        @.importService.graph.allData (data)=>
          data.assert_Size_Is_Bigger_Than(1700)                            # there should be a large number of triplets
          @.importService.graph.db.nav('Library').archIn('is')
                        .solutions (err,data) ->
                            data.assert_Size_Is 1

                            #move this into a class
                            target_Folder = './Lib_UNO-json'.assert_Folder_Exists()
                                                            .path_Combine('Graph_Data').folder_Create().assert_Folder_Exists()
                            target_File   = target_Folder.path_Combine 'lib-uno-triplets.json'
                            using tmGuidance, ()->
                              @.importService.graph.allData (data)=>
                                data.save_Json target_File
                                target_File.assert_File_Exists()

                                done()
