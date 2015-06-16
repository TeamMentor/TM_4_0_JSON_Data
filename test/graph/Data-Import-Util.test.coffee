return

expect          = require('chai'     ).expect
Data_Import_Util = require('./../../src/graph/Data-Import-Util')

describe '| services | data | Data-Import-Util.test', ->

  describe 'core',->
    it 'check ctor',->
      dataImport = new Data_Import_Util()
      expect(Data_Import_Util).to.be.an('function')
      expect(dataImport      ).to.be.an('object')
      expect(dataImport.data ).to.be.an('array')
      expect(dataImport.data ).to.be.empty

      expect(dataImport.addMapping ).to.equal(dataImport.add_Triplet )
      expect(dataImport.addMappings).to.equal(dataImport.add_Triplets)

    it 'check ctor(data)',->
      data=['a','b']
      dataImport = new Data_Import_Util(data)
      dataImport.data.assert_Is_Equal_To    (data)
      dataImport.data.assert_Is_Equal_To    (['a','b'])
      dataImport.data.assert_Is_Not_Equal_To(['a','b','c'])

    it 'addMapping', ->
      dataImport = new Data_Import_Util()
      expect(dataImport.addMapping   ).to.be.an('function')
      expect(dataImport.addMapping('a','b','c')).to.equal(dataImport)
      expect(dataImport.data.size()           ).to.equal(1)
      expect(dataImport.data.first().subject  ).to.equal('a')
      expect(dataImport.data.first().predicate).to.equal('b')
      expect(dataImport.data.first().object   ).to.equal('c')

    it 'addMappings (using array)', ->
      subject = 'a'
      mappings = [{ b: 'c'} , {d:'f'}]
      result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                   { subject: 'a', predicate: 'd', object: 'f' } ]

      dataImport = new Data_Import_Util()
      expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
      expect(dataImport.data                         ).to.deep.equal(result)

    it 'addMappings (using object)', ->
      data = []
      subject = 'a'
      mappings = { b: 'c' , d:'f'}
      result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                   { subject: 'a', predicate: 'd', object: 'f' } ]

      dataImport = new Data_Import_Util()
      expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
      expect(dataImport.data                         ).to.deep.equal(result)

    it 'addMappings (using object with array)', ->
      subject = 'a'
      mappings = { b: 'c' , d: ['f','g']}
      result =   [ { subject: 'a', predicate: 'b', object: 'c' },
                   { subject: 'a', predicate: 'd', object: 'f' }
                   { subject: 'a', predicate: 'd', object: 'g' }]

      dataImport = new Data_Import_Util()
      expect(dataImport.addMappings(subject,mappings)).to.equal(dataImport)
      expect(dataImport.data                         ).to.deep.equal(result)

    it 'graph_From_Data',(done)->
      data = [{subject:'a', predicate: 'b',object:'c'}]
      result =
        nodes: [ { id: 'a' }, { id: 'c' } ]
        edges: [ { from: 'a', to: 'c', label: 'b' } ]

      dataImport = new Data_Import_Util(data)
      dataImport.graph_From_Data.assert_Is_Function()
      dataImport.graph_From_Data (graph) ->
        graph.assert_Is_Equal_To result
        done()

    it 'graph_From_Data (subject with long string)',(done)->
      data = [{subject:'a'.add_Random_Letters(100)}]
      using new Data_Import_Util(data),->
        @.graph_From_Data (graph) ->
          graph.edges[0].from.assert_Size_Is(43)
          done()

    #it 'test - import contents json', (done)->
    #  @timeout 10000
    #  console.time('json load')
    #  contents_Json = __dirname.path_Combine('../../../.tmCache/contents.json').load_Json()
    #  console.timeEnd('json load')
    #  message   = "put #{contents_Json.size()}".log()
    #  tripplets = contents_Json #.take(20000)
    #  message   = "put #{tripplets.size()}"
    #  Graph_Service  = require('./../../../src/services/graph/Graph-Service')

    #  graphService = new Graph_Service(name:'tm-uno')
    #  graphService.openDb ->

    #    console.time(message)
    #    for tripplet in tripplets
    #      graphService.db.put [tripplet]

    #    graphService.allData (allData)->
    #      log allData.size()
    #    #graphService.db.put tripplets, ->
    #    #  log tripplets.size()

    #      console.log 'done'
    #      console.timeEnd(message)
    #      graphService.closeDb ->
    #        done()