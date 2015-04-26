async           = require 'async'
Content_Service = require '../src/Content-Service'

describe '| Content-Service |', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.options    .assert_Is {}
      @.target_Repo.assert_Is './Lib_UNO'


  it 'construtor (with params)',->
    options = { target_Repo : 'abc'}
    using new Content_Service(options), ->
      @.options    .assert_Is(options)
      @.target_Repo.assert_Is(options.target_Repo )


  it 'library_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)->
        folder.assert_Folder_Exists()
              .assert_Contains('Lib_UNO')
              .assert_Contains(process.cwd())
        done()

  it 'library_Json_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.library_Json_Folder (json_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          json_Folder   .assert_Is(library_Folder.append('-json'))
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

  it 'load_Data', (done)->
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
        async.each xml_Files.take(10), check_File, done