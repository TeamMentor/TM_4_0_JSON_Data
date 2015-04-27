#Import_Service   = require '../services/data/Import-Service'
Content_Service  = require './Content-Service'
Wiki_Service     = require './render/Wiki-Service'
Markdown_Service = require './render/Markdown-Service'

class Article

#  constructor: (importService)->
#    @.importService  = importService || new Import_Service(name:'tm-uno')
  constructor: ()->
    @.contentService = new Content_Service()

  ids: (callback)=>
    @.contentService.article_Ids callback
#    @.importService.graph_Find.find_Using_Is 'Article', (articles_Ids)=>
#      callback articles_Ids

#  graph_Data: (article_Id, callback)=>
#    @.importService.graph_Find.get_Subject_Data article_Id, callback

  file_Path: (article_Id, callback)=>
    #log article_Id
    #@.graph_Data article_Id, (article_Data)=>
    #  if article_Data
    #    guid = article_Data.guid
    @.contentService.json_Files (jsonFiles)=>
      path = jsonFile for jsonFile in jsonFiles when jsonFile.contains article_Id
      callback path

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
    @.raw_Data article_Id, (data)=>
      html = null
      if data
        content = data.TeamMentor_Article.Content.first()
        dataType    = content['$'].DataType
        raw_Content = content.Data.first()
        switch (dataType.lower())
          when 'wikitext'
            html = new Wiki_Service().to_Html raw_Content
          when 'markdown'
            html = new Markdown_Service().to_Html raw_Content
          else
            html = raw_Content

      callback html


module.exports = Article