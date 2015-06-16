target_Folder = null

String::cache_Clear = ()->
  @.cache_File_Path().delete_File()

String::cache_Get = ()->
  @.cache_File_Path().load_Json()

String::cache_Target_Folder = ()->
  target_Folder

String::cache_File_Path = ()->
  target_Folder.path_Combine "#{@.to_Safe_String()}.json"

String::cache_Exists = ()->
  @.cache_File_Path().file_Exists()

String::cache_Set = (data)->
  path = @.cache_File_Path()
  if data
    data.save_Json path
  else
    path.delete_File()
  data

String::cache_Set_Target_Folder = ()->
  target_Folder = @.folder_Create()

String::cache_Use =  (getData)->
  if not @.cache_Exists (@)
    @.cache_Set getData()
  @.cache_Get()



#folder_Mappings = ()=>
#  folder_Lib_UNO_Json.path_Combine 'Mappings'
#                     .folder_Create()