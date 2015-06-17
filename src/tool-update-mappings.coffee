#!/usr/bin/env coffee

require './set-globals'

Search_Artifacts_Service = require('./services/Search-Artifacts-Service')
Content_Service          = require '../src/services/Content-Service'

search_Artifacts = new Search_Artifacts_Service()
content_Service  = new Content_Service()

"...  convert Xml files into Json".log()
content_Service.convert_Xml_To_Json ->
  article_Ids = content_Service.article_Ids()

  "... parsing articles json".log()
  search_Artifacts.parse_Articles article_Ids, ->
    "all done".log()
