require 'fluentnode'

class Data_Import_Util
  constructor: (data)->
      @data = data || []

  add_Triplet: (subject, predicate, object)->
    @data.push({ subject:subject , predicate:predicate  , object:object })
    @

  add_Triplets: (subject, mappings)->
    if typeof(mappings.length) != 'undefined'   # is an array
      for mapping in mappings
        for key, value of mapping
          @data.push({ subject:subject , predicate:key  , object:value})
    else
      for key, value of mappings
        if (typeof(value) == 'string')
          @data.push({ subject:subject , predicate:key  , object:value})
        else
          for item in value
            @data.push({ subject:subject , predicate:key  , object:item})
    @

  graph_From_Data: (callback)->
    nodes = []
    edges = []

    addNode =  (node)->
      nodes.push(node) if node not in nodes

    addEdge =  (from, to, label)->
      edges.push({from: from , to: to , label: label})

    for triplet in @data
      if (triplet.subject.length > 40)
        triplet.subject =  triplet.subject.substring(0,40) + "..."
      addNode(triplet.subject)
      addNode(triplet.object)
      addEdge(triplet.subject, triplet.object, triplet.predicate)

    nodes = ({id: node} for node in nodes)

    graph = { nodes: nodes, edges: edges }

    callback(graph)

Data_Import_Util::addMapping  = Data_Import_Util::add_Triplet
Data_Import_Util::addMappings = Data_Import_Util::add_Triplets


module.exports = Data_Import_Util