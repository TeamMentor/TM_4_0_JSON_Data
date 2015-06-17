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
    #json_Files = @.json_Files()
    #if json_Files.not_Empty() and @.force_Reload is false
    #  callback()
    #else

    source_Xml_Files_Folder  = @.folder_Lib_UNO
    target_Json_Files_Folder = @.folder_Library()

    source_Files = @.map_Source_Files()  #library_Folder.files_Recursive(".xml")
    file_Ids     = source_Files.keys()

    convert_Xml_File = (id, next)=>

      source_File = source_Files[id]

      xml_File  = source_Xml_Files_Folder.path_Combine source_File.xml_File
      json_File = target_Json_Files_Folder.path_Combine source_File.json_File
      source_File.checksum

      #json_File = file.replace(library_Folder, json_Folder)
      #                .replace('.xml','.json')

      json_File.parent_Folder().folder_Create()
      contents = xml_File.file_Contents()
      checksum  = contents.checksum()
      if source_File.checksum is checksum
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
          next()

    async.each file_Ids,convert_Xml_File, callback
    'source_Files'.cache_Set source_Files

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


  folder_Search_Data: (callback)=>
    @.folder_Lib_UNO_Json.path_Combine 'Search_Data'
                         .folder_Create()

  map_Source_Files: ()=>
    'source_Files'.cache_Use (callback)=>
      data = {}
      for file in @.folder_Lib_UNO.files_Recursive(".xml")
        file_Key = file.file_Name_Without_Extension()
        file_Data =
          xml_File  : file.remove @.folder_Lib_UNO
          json_File : file.remove(@.folder_Lib_UNO).replace('.xml','.json')
          checksum  : null
          xml_Size  : null
        data[file_Key] = file_Data
      data


module.exports = Content_Service