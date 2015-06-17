path            = require 'path'
async           = require 'async'
Content_Service = require '../../src/services/Content-Service'

#NOTE: for now the order of these tests mater since they create artifacts used (in sequence)

describe '| Content-Service |', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.folder_Lib_UNO     .assert_Is global.config.tm_graph.folder_Lib_UNO
                           .assert_Contains '/Lib_UNO'
      @.folder_Lib_UNO_Json.assert_Is global.config.tm_graph.folder_Lib_UNO_Json
                           .assert_Contains '/Lib_UNO-json'

  it 'folder_Articles_Html, folder_Library, folder_Mappings, folder_Search_Data', ->
    using contentService,->
      check_Folder = (method, folder_Name)=>
        method().assert_Is @.folder_Lib_UNO_Json.path_Combine folder_Name

      check_Folder @.folder_Articles_Html, 'Articles_Html'
      check_Folder @.folder_Library      , 'Library'
      #check_Folder @.folder_Mappings     , 'Mappings'
      check_Folder @.folder_Search_Data  , 'Search_Data'


  it 'convert_Xml_To_Json', (done)->
    @timeout 15000

    files = contentService.json_Files()
    #return done() if files.keys().not_Empty()

    using contentService,->
      @.convert_Xml_To_Json ()=>
        jsons = @.json_Files()
        source_Files = @.map_Source_Files()
        jsons.keys().assert_Not_Empty()
                    .assert_Size_Is source_Files.keys().size() + 4
        done()

  describe 'After load_Data |',->

    it 'article_Data', (done)->
      using contentService,->
        check_File = (xml_File, next)=>
          article_Id  = xml_File.file_Name().remove('.xml')
          article_Data = @.article_Data article_Id
          if (article_Data.TeamMentor_Article)
            using article_Data.TeamMentor_Article, ->
              @.assert_Is_Object()
              @.Metadata.assert_Is_Object()
              @.Content.assert_Is_Object()
          next()

        async.each @.map_Source_Files().keys().take(5), check_File, done

    it 'article_Ids', (done)->
      using contentService,->
        json_Files = @.json_Files()
        article_Ids = @.article_Ids()
        article_Ids.assert_Is_Array()
          #log article_Ids.size()
          #json_Files.assert_Size_Is article_Ids.size() + 1  # because the library XML should not be included (in this case UNO.XML)
        done();