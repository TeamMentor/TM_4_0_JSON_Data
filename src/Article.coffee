#Import_Service   = require '../services/data/Import-Service'
Content_Service  = require './Content-Service'
Wiki_Service     = require './render/Wiki-Service'
Markdown_Service = require './render/Markdown-Service'

class Article

  constructor: ()->
    @.contentService = new Content_Service()

  ids: (callback)=>
    @.contentService.article_Ids callback

  file_Path: (article_Id, callback)=>

    source_Files = @.contentService.map_Source_Files
    if source_Files[article_Id]
      callback @.contentService.folder_Lib_UNO_Json.path_Combine source_Files[article_Id].json_File
    else
      callback null

    #jsonFiles = @.contentService.json_Files (jsonFiles)=>
    #path = jsonFile for jsonFile in jsonFiles when jsonFile.contains article_Id
    #callback path
    #callback @.contentService.folder_Lib_UNO_Json.path_Combine jsonFiles[article_Id]

  raw_Data: (article_Id, callback)=>
    @.file_Path article_Id, (path)=>
      if path
        callback path.load_Json()
      else
        callback null

  raw_Content: (article_Id, callback)=>
    @.file_Path article_Id, (path)=>
      if path
        data = path.load_Json()
        callback data.TeamMentor_Article.Content.first().Data.first()
      else
        callback null

  content_Type: (article_Id, callback)=>
    @.raw_Data article_Id, (data)=>
      if data
        callback data.TeamMentor_Article.Content.first()['$'].DataType
      else
        callback null

  html: (article_Id, callback)=>
    article_Checksums = 'articles_Checksums'.cache_Get() || {}

    @.file_Path article_Id, (path)=>
      #checksum    =  path.file_Contents().checksum()

      callback null

    return
    @.raw_Data article_Id, (data)=>
      html = null
      if data
        content = data.TeamMentor_Article.Content.first()

        dataType    = content['$'].DataType
        raw_Content = content.Data.first()

        if article_Checksums[article_Id] is checksum
          "... skipping #{article_Id}".log()
          return callback null
        "> creating html for #{article_Id}".log()

        switch (dataType.lower())
          when 'wikitext'
            html = new Wiki_Service().to_Html raw_Content
          when 'markdown'
            html = new Markdown_Service().to_Html raw_Content
          else
            html = raw_Content

        article_Checksums[article_Id] = checksum
        'articles_Checksums'.cache_Set article_Checksums
      callback html


module.exports = Article