#!/usr/bin/env coffee

require './set-globals'

Search_Artifacts_Service = require('./services/Search-Artifacts-Service')
Content_Service          = require '../src/services/Content-Service'
TM_Guidance              = require '../src/graph/TM-Guidance'
Import_Service           = require '../src/graph/Import-Service'

search_Artifacts = new Search_Artifacts_Service()
content_Service  = new Content_Service()
importService    = new Import_Service(name: '_tm_uno_test')
tm_Guidance      = new TM_Guidance { importService : importService}

"... convert Xml files into Json".log()
content_Service.convert_Xml_To_Json ->
  article_Ids = content_Service.article_Ids()

  "... parsing articles json".log()
  search_Artifacts.parse_Articles article_Ids, ->

    "... creating tripplets from metadata".log()
    tm_Guidance.load_Data ->
      importService.graph.allData (data)=>
        content_Service.save_Triplets data, ->
          "... deleteting temp db".log()
          tm_Guidance.importService.graph.deleteDb ->

            '... creating search mappings'.log()
            search_Artifacts.create_Search_Mappings ->
              "... data generation complete".log()




