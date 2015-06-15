path            = require 'path'
async           = require 'async'
Content_Service = require '../src/Content-Service'

#NOTE: for now the order of these tests mater since they create artifacts used (in sequence)

describe.only '| Content-Service |', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.options    .assert_Is {}
      @.target_Repo.assert_Is global.config.tm_graph.folder_Lib_UNO
                   .assert_Contains '/Lib_UNO'

  it 'library_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        folder.assert_Is @.target_Repo
        done()

  it 'library_Json_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.library_Json_Folder (json_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          json_Folder   .assert_Is(library_Folder.append("-json#{path.sep}Library"))
          done()

  it 'Search_Data_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.search_Data_Folder (search_Data_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          search_Data_Folder   .assert_Is(library_Folder.append("-json#{path.sep}Search_Data"))
          done()

  it 'convert_Xml_To_Json', (done)->
    @timeout 15000
    contentService.json_Files (files)->
      (done();return) if files.not_Empty()
      using contentService,->
        @.convert_Xml_To_Json ()=>
          @.library_Json_Folder (json_Folder, library_Folder)=>
            @json_Files (jsons)=>
              @xml_Files (xmls)->
                xmls.assert_Not_Empty()
                    .assert_Size_Is(jsons.size())
                done()

  xit 'load_Data', (done)->
    @timeout 60000
    using contentService,->
      @library_Json_Folder (json_Folder, library_Folder)=>
        @._json_Files = null
        @load_Data =>
          @json_Files (jsons)=>
            @xml_Files (xmls)=>
              xmls.assert_Size_Is(jsons.size())
              done()

  it 'article_Data', (done)->
    using contentService,->
      check_File = (xml_File, next)=>
        article_Id  = xml_File.file_Name().remove('.xml')
        @article_Data article_Id, (article_Data)->
          if (article_Data.TeamMentor_Article)
            using article_Data.TeamMentor_Article, ->
              @.assert_Is_Object()
              @.Metadata.assert_Is_Object()
              @.Content.assert_Is_Object()
          next()

      @.xml_Files (xml_Files)->
        async.each xml_Files.take(5), check_File, done

  it 'article_Ids', (done)->
    using contentService,->
      @.json_Files (json_Files)=>
        @.article_Ids (article_Ids)=>
          json_Files.assert_Size_Is article_Ids.size() + 1  # because the library XML should not be included (in this case UNO.XML)
          done();