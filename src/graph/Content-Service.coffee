require 'fluentnode'
path = require 'path'

class Content_Service
  constructor: (options)->
    @.options         = options || {}
    @.force_Reload    = true       # since this is now running on CI, we want to force reload
    @._json_Files     = null
    #@.content_Folder  = @.options.content_Folder  || ".tmCache"
    @.current_Library = @.options.current_Library || "Lib_UNO"

  library_Folder: (callback)=>
    folder = __dirname.path_Combine('../../')
                      #.path_Combine(@.content_Folder)
                      .path_Combine(@.current_Library)
    callback(folder)

  library_Json_Folder: (callback)=>
    @.library_Folder (library_Folder)=>
      json_Folder = library_Folder.append("-json#{path.sep}Library")
      json_Folder.folder_Create()
      callback json_Folder, library_Folder

  json_Files: (callback)=>
    if @._json_Files and @._json_Files.not_Empty()
      callback @._json_Files
    else
      @.library_Json_Folder (json_Folder, library_Folder)=>
        @._json_Files = json_Folder.files_Recursive(".json")
        callback @._json_Files
  article_Data: (articleId, callback) =>
    @json_Files (jsonFiles) =>
      article_File = jsonFile for jsonFile in jsonFiles when jsonFile.contains(articleId)
      if article_File and article_File.file_Exists()
        callback article_File.load_Json().TeamMentor_Article
      else
        callback null

module.exports = Content_Service