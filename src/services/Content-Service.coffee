require 'fluentnode'
path    = require 'path'
xml2js  = require 'xml2js'
async   = require 'async'

class Content_Service

  constructor: ()->
    @.force_Reload        = true            # since this is now running on CI, we want to force reload
    @._json_Files         = null
    @._xml_Files          = null
    @.folder_Lib_UNO      = global.config?.tm_graph?.folder_Lib_UNO
    @.folder_Lib_UNO_Json = global.config?.tm_graph?.folder_Lib_UNO_Json

  article_Data: (articleId) =>
    article_Json = @.json_Files()[articleId]
    if article_Json
      article_File = @.folder_Lib_UNO_Json.path_Combine article_Json
      if article_File.file_Exists()
        return article_File.load_Json()

  article_Ids: (callback)=>
    #fileNames = (json_File.file_Name_Without_Extension() for json_File in @.json_Files())
    #article_Ids = (filename for filename in fileNames when filename.split('-').size() is 5)
    #callback article_Ids.take -1
    keys = @.map_Source_Files().keys()
    return (key for key in keys when key.split('-').size() is 5)

  convert_Xml_To_Json: (callback)=>
    source_Xml_Files_Folder  = @.folder_Lib_UNO
    target_Json_Files_Folder = @.folder_Library()
    html_Articles_Folder     = @.folder_Articles_Html()


    source_Files = @.map_Source_Files()
    file_Ids     = source_Files.keys()

    convert_Xml_File = (id, next)=>

      source_File = source_Files[id]

      xml_File  = source_Xml_Files_Folder.path_Combine source_File.xml_File
      json_File = target_Json_Files_Folder.path_Combine source_File.json_File
      data_File = html_Articles_Folder.path_Combine "#{id.substring(0,2)}/#{id}.json"

      return next() if xml_File.file_Not_Exists()

      json_File.parent_Folder().folder_Create()
      contents  = xml_File.file_Contents()
      checksum  = contents.checksum()
      if json_File.file_Exists() and source_File.checksum is checksum
        #"...skipping file #{source_File.xml_File}".log()
        next()
      else
        "[convert_Xml_File] converting xml file into json: #{source_File.xml_File}".log()
        xml2js.parseString xml_File.file_Contents(), (error, json) ->
          if error
            "[convert_Xml_File] Error converting file #{source_File.xml_File} into json".log()
          else
            json.save_Json(json_File)
            source_File.checksum  = checksum
            source_File.xml_Size  = contents.length
            if data_File.file_Exists()
              data_File.file_Delete()
          next()

    async.each file_Ids,convert_Xml_File, ->
      'source_Files'.cache_Set source_Files
      callback()

  json_Files: ()=>
    'json_Files'.cache_Use (callback)=>
      data = {}
      for file in @.folder_Lib_UNO_Json.files_Recursive(".json")
        data[file.file_Name_Without_Extension()] = file.remove @.folder_Lib_UNO_Json
      data

    #if @._json_Files and @._json_Files.not_Empty()
    #  callback @._json_Files
    #else
    #  @._json_Files = @.folder_Lib_UNO_Json.files_Recursive(".json")
    #  callback @._json_Files


  folder_Articles_Html: (callback)=>
     @.folder_Lib_UNO_Json.path_Combine 'Articles_Html'
                          .folder_Create()

  folder_Library: (callback)=>
    @.folder_Lib_UNO_Json.path_Combine 'Library'
                         .folder_Create()

  #folder_Mappings: (callback)=>
  #  @.folder_Lib_UNO_Json.path_Combine 'Mappings'
  #  .folder_Create()


  folder_Search_Data: ()=>
    @.folder_Lib_UNO_Json.path_Combine 'Search_Data'
                         .folder_Create()

  map_Source_Files: ()=>
    xml_File    = @.folder_Lib_UNO.path_Combine 'UNO.xml'
    xml_Content = xml_File.file_Contents()
    'source_Files'.cache_Use ()=>
      data = {}
      for file in @.folder_Lib_UNO.files_Recursive(".xml")
        file_Key = file.file_Name_Without_Extension()
        #Just converting articles in a view
        if not xml_Content.contains(file_Key) && file_Key isnt 'UNO'
          continue
        mapping =
          xml_File  : file.remove @.folder_Lib_UNO
          #checksum  : null
          #xml_Size  : null
        mapping.json_File = mapping.xml_File.replace('.xml','.json')
        mapping.data_File = "/#{file_Key.substring(0,2)}/#{file_Key}.json"
        data[file_Key] = mapping
      data

  save_Triplets: (data,callback)=>
    target_Folder = @.folder_Lib_UNO_Json.path_Combine('Graph_Data').folder_Create()
    target_File   = target_Folder.path_Combine 'lib-uno-triplets.json'
    data.save_Json target_File
    callback target_File

module.exports = Content_Service