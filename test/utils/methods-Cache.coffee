require '../../src/utils/methods-Cache'

describe '| services | Content-Service |', ->

  test_Folder     = '_tmp_Cache_folder'
  original_Folder = ''.cache_Target_Folder()
  before ->
    test_Folder.cache_Set_Target_Folder()

  after ->
    test_Folder.folder_Delete_Recursive().assert_Is_True()
    original_Folder.cache_Set_Target_Folder()

  it 'cache_Target_Folder', ->
    "".cache_Target_Folder().assert_Is test_Folder.real_Path()
                            .assert_Folder_Exists()

  it 'cache_Get, cache_File_Path, cache_Exists, cache_Set', ->
    key   = "_tmp_an_key_".add_5_Letters()
    value = "_tmp_an_value_".add_5_Letters()

    file  = key.cache_File_Path().assert_Is ''.cache_Target_Folder().path_Combine "#{key}.json"

    file.assert_File_Not_Exists()
    assert_Is_Null key.cache_Get()

    key.cache_Exists()  .assert_Is_False()
    key.cache_Set(value).assert_Is value
    key.cache_Get()     .assert_Is value
    key.cache_Exists()  .assert_Is_True()
    file                .assert_File_Exists( )

    file.assert_File_Deleted()
    key.cache_Exists( ) .assert_Is_False()
    assert_Is_Null key.cache_Get()

  it 'cache_Use', ()->
    key   = "_tmp_an_key_".add_5_Letters()
    value = "_tmp_an_value_".add_5_Letters()
    assert_Is_Null key.cache_Get()
    key.cache_Use(()-> value).assert_Is value
    key.cache_Get()          .assert_Is value
    key.cache_Set null
    assert_Is_Null key.cache_Get()
