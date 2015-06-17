async             = require 'async'
cheerio           = require 'cheerio'

if not library_Name
  library_Name = 'Guidance'

take = -1

class TM_Guidance
  constructor: (options)->
    @.options = options || {}
    @.importService     = @options.importService
    @.library           = null
    @.library_Name      = 'Guidance'
    @.metadata_Queries  = null
    @.library_Name = if (global.request_Params) then global.request_Params.query['library'] else null

  setupDb: (callback)=>
    @.importService.graph.deleteDb =>
      @.importService.graph.openDb =>
        @importService.library_Import.library (data)->
          @.library = data
          callback()

  create_Metadata_Global_Nodes: (next)=>
    @.metadata_Queries  = {}
    importUtil = @.importService.graph_Add_Data.new_Data_Import_Util()

    add_Metadata_Global_Node = (target)=>
      target_Id = @.importService.graph_Add_Data.new_Short_Guid('query')
      importUtil.add_Triplet target_Id, 'title', target
      importUtil.add_Triplet target_Id, 'is', 'Query'
      importUtil.add_Triplet target_Id, 'is', 'Metadata'
      if @.metadata_Queries
        @.metadata_Queries[target] = target_Id

    add_Metadata_Global_Node(target) for target in ['Category', 'Phase', 'Technology', 'Type']

    @.importService.graph.db.put importUtil.data, ()=>
      next()

  import_Article_Metadata: (article_Id, article_Data, next)=>
    importUtil = @importService.graph_Add_Data.new_Data_Import_Util()

    add_Metadata_Target = (target)=>
      target_Value      = article_Data.Metadata?.first?()[target]?.first()
      if (target_Value)
        target_Global_Id = @.metadata_Queries[target]
        target_Id        = @.metadata_Queries[target_Value]

        if not target_Id
          target_Id = @.metadata_Queries[target_Value] = @.importService.graph_Add_Data.new_Short_Guid('query')
          importUtil.add_Triplet(target_Id       , 'is','Query')
          importUtil.add_Triplet(target_Global_Id, 'contains-query',target_Id)
        importUtil.add_Triplet(target_Id         , 'contains-article', article_Id)
        importUtil.add_Triplet(target_Id         , 'title', target_Value)
        importUtil.add_Triplet(article_Id        , target.lower(), target_Value)

    add_Article_Summary = ()=>
      html       = article_Data.Content.first().Data.first()
      summary    = ""
      if (article_Data.Content.first()['$'].DataType.lower() is 'html')
        $          = cheerio.load(html.substring(0,1050))
        summary    = $('p').text().substring(0,200).trim()
      else
        summary = html.substring(0,200).replace(/\*/g,'').replace(/\=/g,'')

      importUtil.add_Triplet(article_Id, 'summary', summary)

    add_Article_Tag = ()=>
      technology_Value = article_Data.Metadata.first().Technology?.first()
      tag_Value        = article_Data.Metadata.first().Tag?.first()
      if not tag_Value                                                    # if there is not Tag value, use the technology value
        tag_Value = technology_Value?.split(' ').join(',')                # splited by space and joined by comma
      importUtil.add_Triplet(article_Id  , 'tags', tag_Value || "")       # the metadata called it Tag but it better to normalize it to tags

    add_Metadata_Target(target) for target in ['Phase', 'Technology', 'Type'] # 'Category'
    add_Article_Summary();
    add_Article_Tag();

    @.importService.graph.db.put importUtil.data, ()=>
      next()

  import_Article: (article, next)=>
    @.importService.library_Import.article_Data article.guid, (article_Data)=>
      if (article_Data? and article_Data.Metadata)
        title = article_Data.Metadata.first().Title.first()
        if title isnt undefined
          @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Article', article.guid, title, (article_Id)=>
            @.importService.graph.add article.parent, 'contains-article', article_Id, =>
              @.import_Article_Metadata article_Id, article_Data, next
        else
          next()
      else
        next()

  import_Articles: (parent, article_Ids, next)=>
    articlesToAdd = ({guid: article_Id, parent:parent} for article_Id in article_Ids).take(take)
    async.each articlesToAdd, @import_Article, next

  import_View: (view, next)=>
    @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Query', view.guid, view.title, (view_Id)=>
      @.importService.graph.add view.parent, 'contains-query', view_Id, =>
        @.import_Articles view_Id, view.articles, next

  import_Views: (parent, views, next)=>
    viewsToAdd = ({guid: view.id, title: view.name, parent:parent,articles: view.articles} for view in views).take(take)
    async.each viewsToAdd, @.import_View, next

  import_Folder: (folder, next)=>
    @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Query', folder.guid, folder.title, (folderId)=>
      @.importService.graph.add folder.parent, 'contains-query', folderId, =>
        @.import_Views folderId, folder.views , =>
          @.import_Folders folderId, folder.folders , next

  import_Folders: (parent, folders, next)=>
    foldersToAdd = ({guid: folder.id, title: folder.name, parent:parent, views:folder.views, folders: folder.folders} for folder in folders).take(take)
    async.each foldersToAdd, @.import_Folder, -> next()

  import_Library: (guid, title, next)=>
    @.importService.graph_Add_Data.add_Db_using_Type_Guid_Title 'Query', guid, title, (library_Id)=>
      @.importService.graph_Add_Data.add_Is library_Id, 'Library', ->
        next(library_Id)

  load_Data: (callback)=>
    @.setupDb =>
      @.importService.library_Import.library (library)=>
        @.create_Metadata_Global_Nodes =>
          @.import_Library library.id, library.name, (library_Id)=>
              @.import_Folders library_Id, library.folders, =>
                @.import_Views library_Id, library.views, =>
                  @.importService.graph.closeDb =>
                    @.importService.graph.openDb =>
                      #"[tm-uno] finished loading data".log()
                      callback()

  reload_Data: (skip_If_Exists, callback)=>
    if skip_If_Exists and @.importService.graph.dbPath.folder_Exists()
      return callback()
    @.load_Data callback

module.exports = TM_Guidance
