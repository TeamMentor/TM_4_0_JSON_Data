Guid                    = require('teammentor').Guid
Data_Import_Util        = require './Data-Import-Util'
Content_Service         = require './Content-Service'
Library_Import_Service  = require './Library-Import-Service'
levelgraph              = null
levelup                 = null
class Graph_Service
  dependencies: ->
    levelgraph        = require 'levelgraph'
    levelup           = require("levelup");

  constructor: (options)->
    @.dependencies()
    @.options       = options || {}
    @.dbName        = @.options.name || '_tmp_db'.add_Random_String(5)
    @.dbPath        = "./.tmCache/#{@dbName}"
    @.db            = null

  add: (subject, predicate, object, callback)=>
    if @.db is null
      callback null
      return
    @db.put([{ subject:subject , predicate:predicate  , object:object }], callback)

  allData: (callback)=>
    if @.db is null
      callback null
      return
    @db.search [{
                  subject  : @db.v("subject"),
                  predicate: @db.v("predicate"),
                  object   : @db.v("object"),
                }], (err, data)->callback(data)

  closeDb: (callback)=>
    if (@db)
      @db.close =>
        @db    = null
        @level = null
        callback()
    else
      callback()

  deleteDb: (callback)->
    @closeDb =>
      @dbPath.folder_Delete_Recursive()
      callback();

  openDb: (callback)->
    @.dbPath.parent_Folder().folder_Create()
    @db = levelgraph(levelup(@dbPath))
    process.nextTick =>
      callback()


class Graph_Add_Data
  constructor                 : (graph                      )-> @.graph = graph

  new_Data_Import_Util        : (data                       )-> new Data_Import_Util(data)
  new_Short_Guid              : (title, guid                )-> new Guid(title, guid).short
  add_Db_using_Type_Guid_Title: (type, guid, title, callback)=> @.add_Db type.lower(), guid, {'guid' : guid, 'is' :type, 'title': title}, callback
  add_Is                      : (id, is_Value, callback     )=> @.graph.add id,'is',is_Value, callback

  add_Db: (type, guid, data, callback)=>
    id = @.new_Short_Guid(type,guid)
    importUtil = @.new_Data_Import_Util()
    importUtil.add_Triplets(id, data)
    @.graph.db.put importUtil.data, -> callback(id)




class Import_Service
  constructor: (options)->
    @.graph           = new Graph_Service(options)
    @.name            = options.name || '_tmp_import'
    @.content         = new Content_Service()
    @.library_Import  = new Library_Import_Service @.content
    @.graph_Add_Data  = new Graph_Add_Data @.graph
    @.path_Root       = ".tmCache"
    @.path_Name       = ".tmCache/#{@.name}"

  setup: (callback)->
    @path_Root   .folder_Create()
    @path_Name   .folder_Create()

    @graph.openDb ->
      callback()

module.exports = Import_Service