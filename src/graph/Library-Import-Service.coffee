class Library_Import_Service

  constructor: (content)->
    @.content = content

  library_Json: (callback)=>
    @.content.library_Json_Folder (folder)->
      if  folder.files().empty()
        callback null
      else
        callback folder.files('.json').first().load_Json()     # assumes that there is only one json file which represents the library

  add_Json_Folder: (target_Folders, json_Folder)->
    all_Articles = []
    folder =
      id       : json_Folder['$'].folderId
      name     : json_Folder['$'].caption
      folders  : []
      views    : []

    if json_Folder.view
      for view in  json_Folder.view
        view_Articles = @add_Json_View folder.views, view
        all_Articles = all_Articles.concat(view_Articles)
    if json_Folder.folder1
      for sub_Folder in json_Folder.folder1
        all_Articles = all_Articles.concat(@.add_Json_Folder folder.folders, sub_Folder)

    target_Folders.push folder
    all_Articles

  add_Json_View: (target_Views, json_View)->
    view =
      id       : json_View['$'].id
      name     : json_View['$'].caption
      articles : json_View.items?.first().item || []
    target_Views.push view
    view.articles


  parse_Library_Json: (json,callback)=>
    if not json
      return callback null

    library =
      id      : null
      name    : null
      folders : []
      views   : []
      articles: []

    json_Library    = json.guidanceExplorer.library.first()
    library.id      = json_Library["$"].name
    library.name    = json_Library["$"].caption

    for item in json_Library.libraryStructure
      if (item.folder)
        for folder in item.folder
          library.articles = library.articles.concat(@.add_Json_Folder library.folders,  folder)
      if (item.view)
        for view in item.view
          library.articles = library.articles.concat(@.add_Json_View library.views,  view)
    callback(library)

  library: (callback)=>
    @library_Json (json)=>
      @parse_Library_Json json, callback

  article_Data: (articleId, callback)=>
    @.content.article_Data articleId, (article_Data)->
      callback article_Data

module.exports = Library_Import_Service