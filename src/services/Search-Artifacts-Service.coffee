Article         = null
Content_Service = null
crypto          = null
cheerio         = null
async           = null

checksum = (str, algorithm, encoding)->
  crypto.createHash(algorithm || 'md5')
        .update(str, 'utf8')
        .digest(encoding || 'hex')

class Search_Artifacts_Service

  dependencies: ->
    Article         = require './Article'
    Content_Service = require './Content-Service'
    crypto          = require 'crypto'
    cheerio         = require 'cheerio'
    async           = require 'async'

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.article         = new Article()
    @.content_Service = new Content_Service()
    #@.cache           = new Cache_Service("article_cache")
    #@.cache_Search    = new Cache_Service("search_cache")

  batch_Parse_All_Articles: (callback)=>
    @.article.ids  (article_Ids)=>
      @.parse_Articles article_Ids, callback

  create_Search_Mappings: (callback)=>
    source_Files = @.content_Service.map_Source_Files()

    #@.raw_Articles_Html (articles_Data)=>
    search_Mappings = {}
    #for article_Data in articles_Data
    for mapping in source_Files.values()
      file_Path    =  @.content_Service.folder_Articles_Html().path_Combine(mapping.data_File)
      article_Data = file_Path.load_Json()
      if article_Data
        for word,where of article_Data.words
          if search_Mappings[word] is undefined or typeof search_Mappings[word] is 'function'
            search_Mappings[word] = {}
          search_Mappings[word][article_Data.id] =  where : where #.unique()


    target_Folder = @.content_Service.folder_Search_Data()
    key = target_Folder.path_Combine 'search_mappings.json'
    search_Mappings.save_Json key
    callback search_Mappings

  parse_Article: (article_Id, callback)=>
    folder = @.content_Service.folder_Articles_Html()

    data_Folder = folder.path_Combine "#{article_Id.substring(0,2)}"
    data_File   = data_Folder.path_Combine "#{article_Id}.json"
    html_File   = data_Folder.path_Combine "#{article_Id}.html"

    if data_File.file_Exists()
      setImmediate ->
        callback null
    else
      #"[parse_Article] creating html for #{article_Id}".log()
      @.parse_Article_Html article_Id, (data, html)=>
        data_Folder.folder_Create()
        if (data)
          data.save_Json data_File
        if (html)
          html.save_As html_File
        setImmediate ->
          callback data

  parse_Articles: (article_Ids, callback)=>
    #results = []
    return callback() unless article_Ids # is undefined or article_Ids is null

      #return callback results
    total = article_Ids.size()
    count  = 0
    mapped = 0;
    map_Article = (article_Id, next)=>
      @.parse_Article article_Id, (data)->
        count++
        if data and  (++mapped %% 50) is 0
          console.log( "[parse_Articles] mapped: #{mapped} count: #{count} total: #{total}")
        #results.push data
        next()

    async.eachSeries article_Ids , map_Article, callback
    #()=>
    #  callback results

  parse_Article_Html: (article_Id, callback)=>
    data =
      id       : article_Id
      checksum : null
      words    : {}
      tags     : {}
      links    : []

    @.article.html article_Id, (html)=>
      return callback null if not html
      data.checksum = html.checksum()
      $ = cheerio.load html

      $('*').each (index,item)->
        tagName = item.name
        $tag = $(item)
        text    = $tag.text()
        if tagName is 'a'
          attrs = $tag.attr()
          attrs.text = $tag.text()
          data.links.push attrs

        #data.tags[tagName] ?= []                   # this had quite a big performance implication (35% more in size)
        #data.tags[tagName].push(text.trim())       # and it is not being used
        for word in text.split(/\s+/)
          word = word.trim().lower().replace(/[,\.;\:\n\(\)\[\]<>\"]/g,'')     # this has some performance implications (from 9ms to 18ms) and it might be better to do it on data consolidation
          if word and word isnt ''
            for temp in word.split('-')
              if data.words[temp] is undefined or typeof data.words[temp] is 'function' # need to do this in order to avoid confict with js build in methods (like constructor)
                data.words[temp] = []
              data.words[temp].push(tagName)

      @.article.raw_Data article_Id, (raw_Data)->
        title = raw_Data.TeamMentor_Article.Metadata[0].Title.first()
        for word in title.split(' ')
          word = word.trim().lower().replace(/[,\.;\:\n\(\)\[\]<>]/,'')
          if word isnt ''
            for temp in word.split('-')
              if data.words[temp] is undefined or typeof data.words[temp] is 'function'
                data.words[temp] = []
              data.words[temp].push('title')
        callback data, html

  #raw_Articles_Html: (callback)=>
  #  @.content_Service.search_Data_Folder (data_Folder)=>
  #    key = data_Folder.path_Combine 'raw_articles_html.json'
  #    if key.file_Exists()
  #      callback key.load_Json()
  #    else
  #      "no key for raw_Articles_Html, so calculating them all".log()
  #      @.batch_Parse_All_Articles =>
  #        @.content_Service.articles_Html_Folder (html_Folder)=>
  #          raw_Articles_Html = []
  #          for file in html_Folder.files()
  #            raw_Articles_Html.push file.load_Json()
  #
  #          raw_Articles_Html.save_Json key
  #          callback raw_Articles_Html

module.exports = Search_Artifacts_Service