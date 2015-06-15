if process.cwd().contains('.dist')
  root_Folder = process.cwd().path_Combine '../../../'
else
  root_Folder = process.cwd().path_Combine '../../'

tm_Cache      = root_Folder.path_Combine '.tmCache'

global.config =

  tm_graph:
    folder_Lib_UNO          : root_Folder.path_Combine 'data/Lib_UNO'
    folder_Lib_UNO_Json     : root_Folder.path_Combine 'data/Lib_UNO-Json'
