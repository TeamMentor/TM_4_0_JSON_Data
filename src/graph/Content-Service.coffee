require 'fluentnode'
path = require 'path'

class Content_Service
  constructor: ()->
    @.force_Reload      = true       # since this is now running on CI, we want to force reload
    @._json_Files       = null
    @._html_Files       = null
    @.current_Library   = global.config?.tm_graph?.folder_Lib_UNO

  library_Folder: (callback)=>
    callback @.current_Library

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

  html_Files: (callback)=>
    if @._html_Files
      callback @._html_Files
    else
      @._html_Files = @.current_Library.append('-json/Articles_Html').files_Recursive(".html")
      callback @._html_Files

  article_Data: (articleId, callback) =>
    @json_Files (jsonFiles) =>
      article_File = jsonFile for jsonFile in jsonFiles when jsonFile.contains(articleId)
      if article_File and article_File.file_Exists()
        callback article_File.load_Json().TeamMentor_Article
      else
        callback null

  article_Html:(articleId, callback) =>
    @html_Files (htmlFiles) =>
      article_File = htmlFile for htmlFile in htmlFiles when htmlFile.contains(articleId)
      if article_File and article_File.file_Exists()
        callback article_File.file_Contents()
      else
        callback null

module.exports = Content_Service