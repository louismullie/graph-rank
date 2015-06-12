# Brin, S.; Page, L. (1998). "The anatomy of 
# a large-scale hypertextual Web search engine". 
# Computer Networks and ISDN Systems 30: 107–117.
class GraphRank::PageRank
  
  attr_accessor :graph, :outlinks, :nodes, :weights, :printGraph, :mergeGraphs

  # Initialize with default damping and convergence.
  # A maximum number of iterations can also be supplied
  # (default is no maximum, i.e. iterate until convergence).
  def initialize(damping=nil, convergence=nil, max_it=100)
    damping ||= 0.85; convergence ||= 0.00000000000000000000000001
    if damping <= 0 or damping > 1
      raise 'Invalid damping factor.'
    elsif convergence < 0 or convergence > 1
      raise 'Invalid convergence factor.'
    end
    @damping, @convergence, @max_it = damping, convergence, max_it
    @graph, @outlinks, @nodes, @weights = {}, {}, {}, {}
    
    #flags make sure one of these two is true the other false
    @doPageRank = true
    @doGravityRank = false #underperfs, philosophy: don't divide by num outoing links just like sun's gravity isn't divided by num planets rotating it, but i think in this case it allows a bunch of unimportant unigrams that have high scores because they are keyphrase fragments to support eachother into top posiions, reducing accuracy, just a theory though
    if @doGravityRank
      puts('doing GRAVITY RANK')
      @doPageRank = false
      @max_it = 20
    end
  end

  # Add a node to the graph.
  def add(source, dest, weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    #flag
    @allowSelfEdges = false
    #flag
    
    if not @allowSelfEdges
      return false if source == dest
    end
    @outlinks[source] ||= 0.0
    @graph[dest] ||= []
    
    
    #avoid establishing link if it already exists
    if @graph[dest].include? source
        puts("in page_rank.add link already exists between #{source} and #{dest}")
        return true
    end
    
    @graph[dest] << source
    @outlinks[source] += 1.0 #as long as we are doing normalizeEdgeWeight (which is set to true by default) we don't need this eighter so if there is ever a CLEAN UP consider deleting this
    @nodes[source] = sourcePriorWeight #0.15
    @nodes[dest] = destPriorWeight # 0.15
    @weights[source] ||= {}
    @weights[source][dest] = weight
  end
  
  
  #ensures that all nodes' outgoing edge weights sum to 1
  def normalizeNodeEdgeWeights
    @weights.each do |source, destinatins|
      weightsSum = 0.0
      
      #get sum of edge weights pointing out of this node
      destinatins.each do |dest, edgeWeight|
        weightsSum += edgeWeight
      end
      
      #divide each edge by sum of edge weights
      destinatins.each do |dest, edgeWeight|
        @weights[source][dest] /= weightsSum
      end
      
    end
    
  end

  # Iterates the PageRank algorithm
  # until convergence is reached.
  def calculate
    puts("in page_rank#calculate")
    
    #flag: if set to true, a node's edge weights are divided by the sum of its edge weights
    @normalizeEdgeWeight = true
    if true
      puts("NORMALIZING EDGE WEIGHTS")
      normalizeNodeEdgeWeights
    end
    
    
    done = false
    numiterations = 0
    until done
      #printNodeWeights numiterations
      numiterations += 1      
      break if @max_it == 0
      #puts("right before iteration")
      new_nodes = iteration
      #puts("right after iteration")
      #printGraph new_nodes #for debug
      done = convergence(new_nodes)
      @nodes = new_nodes
      @max_it -= 1
    end
    puts("numiterations = #{numiterations}")
    @nodes.sort_by {|k,v|v}.reverse
  end
  
  def printNodeWeights  iterationNum
    $logFile.puts("printing node weights for iteration #{iterationNum}")
    @nodes.each do |k,v|
      #puts("k = #{k}") 
      if not $logFile.nil?     
        $logFile.puts "weight for #{k} = #{v}"
      end
      puts "weight for #{k} = #{v}"
    end
  end
  
  def printGraph new_nodes = nil, logFile = nil

      puts("printing graph:")
      if not logFile.nil?
        logFile.puts("printing graph:")
      end
      @graph.each do |node,links|
          if not new_nodes.nil?  and new_nodes.has_key? node
            puts("#{node} (#{new_nodes[node]}) <- #{links}")
            if not logFile.nil?
              logFile.puts("#{node} (#{new_nodes[node]}) <- #{links}")
            end
          else
            puts("#{node} <- #{links}")
            if not logFile.nil?
              logFile.puts("#{node} <- #{links}")
            end
          end
          for link in links
            weight = @weights[link][node]
            puts("#{link} edge weight = #{weight}")
            if not logFile.nil?
              logFile.puts("#{link} edge weight = #{weight}")
            end
          end
      end
      puts("--------------------")
  end
  
  
  #print the graph as something like this:
  #for full json see https://docs.google.com/document/d/1l0g9Ta1Tb94jrEZwwps6TTzb8Gc7zHQLHmd4Bno46VI/edit#bookmark=id.e6eluzla2n5v
  #{"nodes":[{"name":"Myriel","group":1},{"name":"Napoleon","group":1},{"name":"Mlle.Baptistine","group":1},{"name":"Mme.Magloire","group":1},{"name":"CountessdeLo","group":1},{"name":"Geborand","group":1},{"name":"Champtercier","group":1},{"name":"Cravatte","group":1},{"name":"Count","group":1},{"name":"OldMan","group":1},{"name":"Labarre","group":2},{"name":"Valjean","group":2},{"name":"Marguerite","group":3},{"name":"Mme.deR","group":2},{"name":"Isabeau","group":2},{"name":"Gervais","group":2},{"name":"Tholomyes","group":3},{"name":"Listolier","group":3},{"name":"Fameuil","group":3},{"name":"Blacheville","group":3},{"name":"Favourite","group":3},{"name":"Dahlia","group":3},{"name":"Zephine","group":3},{"name":"Fantine","group":3},{"name":"Mme.Thenardier","group":4},{"name":"Thenardier","group":4},{"name":"Cosette","group":5},{"name":"Javert","group":4},{"name":"Fauchelevent","group":0},{"name":"Bamatabois","group":2},{"name":"Perpetue","group":3},{"name":"Simplice","group":2},{"name":"Scaufflaire","group":2},{"name":"Woman1","group":2},{"name":"Judge","group":2},{"name":"Champmathieu","group":2},{"name":"Brevet","group":2},{"name":"Chenildieu","group":2},{"name":"Cochepaille","group":2},{"name":"Pontmercy","group":4},{"name":"Boulatruelle","group":6},{"name":"Eponine","group":4},{"name":"Anzelma","group":4},{"name":"Woman2","group":5},{"name":"MotherInnocent","group":0},{"name":"Gribier","group":0},{"name":"Jondrette","group":7},{"name":"Mme.Burgon","group":7},{"name":"Gavroche","group":8},{"name":"Gillenormand","group":5},{"name":"Magnon","group":5},{"name":"Mlle.Gillenormand","group":5},{"name":"Mme.Pontmercy","group":5},{"name":"Mlle.Vaubois","group":5},{"name":"Lt.Gillenormand","group":5},{"name":"Marius","group":8},{"name":"BaronessT","group":5},{"name":"Mabeuf","group":8},{"name":"Enjolras","group":8},{"name":"Combeferre","group":8},{"name":"Prouvaire","group":8},{"name":"Feuilly","group":8},{"name":"Courfeyrac","group":8},{"name":"Bahorel","group":8},{"name":"Bossuet","group":8},{"name":"Joly","group":8},{"name":"Grantaire","group":8},{"name":"MotherPlutarch","group":9},{"name":"Gueulemer","group":4},{"name":"Babet","group":4},{"name":"Claquesous","group":4},{"name":"Montparnasse","group":4},{"name":"Toussaint","group":5},{"name":"Child1","group":10},{"name":"Child2","group":10},{"name":"Brujon","group":4},{"name":"Mme.Hucheloup","group":8}],"links":[{"source":1,"target":0,"value":1},{"source":2,"target":0,"value":8},{"source":3,"target":0,"value":10},{"source":3,"target":2,"value":6},{"source":4,"target":0,"value":1},{"source":5,"target":0,"value":1},{"source":6,"target":0,"value":1},{"source":7,"target":0,"value":1},{"source":8,"target":0,"value":2},{"source":9,"target":0,"value":1},{"source":11,"target":10,"value":1},{"source":11,"target":3,"value":3},{"source":11,"target":2,"value":3},{"source":11,"target":0,"value":5},{"source":12,"target":11,"value":1},{"source":13,"target":11,"value":1},{"source":14,"target":11,"value":1},{"source":15,"target":11,"value":1},{"source":17,"target":16,"value":4},{"source":18,"target":16,"value":4},{"source":18,"target":17,"value":4},{"source":19,"target":16,"value":4},{"source":19,"target":17,"value":4},{"source":19,"target":18,"value":4},{"source":20,"target":16,"value":3},{"source":20,"target":17,"value":3},{"source":20,"target":18,"value":3},{"source":20,"target":19,"value":4},{"source":21,"target":16,"value":3},{"source":21,"target":17,"value":3},{"source":21,"target":18,"value":3},{"source":21,"target":19,"value":3},{"source":21,"target":20,"value":5},{"source":22,"target":16,"value":3},{"source":22,"target":17,"value":3},{"source":22,"target":18,"value":3},{"source":22,"target":19,"value":3},{"source":22,"target":20,"value":4},{"source":22,"target":21,"value":4},{"source":23,"target":16,"value":3},{"source":23,"target":17,"value":3},{"source":23,"target":18,"value":3},{"source":23,"target":19,"value":3},{"source":23,"target":20,"value":4},{"source":23,"target":21,"value":4},{"source":23,"target":22,"value":4},{"source":23,"target":12,"value":2},{"source":23,"target":11,"value":9},{"source":24,"target":23,"value":2},{"source":24,"target":11,"value":7},{"source":25,"target":24,"value":13},{"source":25,"target":23,"value":1},{"source":25,"target":11,"value":12},{"source":26,"target":24,"value":4},{"source":26,"target":11,"value":31},{"source":26,"target":16,"value":1},{"source":26,"target":25,"value":1},{"source":27,"target":11,"value":17},{"source":27,"target":23,"value":5},{"source":27,"target":25,"value":5},{"source":27,"target":24,"value":1},{"source":27,"target":26,"value":1},{"source":28,"target":11,"value":8},{"source":28,"target":27,"value":1},{"source":29,"target":23,"value":1},{"source":29,"target":27,"value":1},{"source":29,"target":11,"value":2},{"source":30,"target":23,"value":1},{"source":31,"target":30,"value":2},{"source":31,"target":11,"value":3},{"source":31,"target":23,"value":2},{"source":31,"target":27,"value":1},{"source":32,"target":11,"value":1},{"source":33,"target":11,"value":2},{"source":33,"target":27,"value":1},{"source":34,"target":11,"value":3},{"source":34,"target":29,"value":2},{"source":35,"target":11,"value":3},{"source":35,"target":34,"value":3},{"source":35,"target":29,"value":2},{"source":36,"target":34,"value":2},{"source":36,"target":35,"value":2},{"source":36,"target":11,"value":2},{"source":36,"target":29,"value":1},{"source":37,"target":34,"value":2},{"source":37,"target":35,"value":2},{"source":37,"target":36,"value":2},{"source":37,"target":11,"value":2},{"source":37,"target":29,"value":1},{"source":38,"target":34,"value":2},{"source":38,"target":35,"value":2},{"source":38,"target":36,"value":2},{"source":38,"target":37,"value":2},{"source":38,"target":11,"value":2},{"source":38,"target":29,"value":1},{"source":39,"target":25,"value":1},{"source":40,"target":25,"value":1},{"source":41,"target":24,"value":2},{"source":41,"target":25,"value":3},{"source":42,"target":41,"value":2},{"source":42,"target":25,"value":2},{"source":42,"target":24,"value":1},{"source":43,"target":11,"value":3},{"source":43,"target":26,"value":1},{"source":43,"target":27,"value":1},{"source":44,"target":28,"value":3},{"source":44,"target":11,"value":1},{"source":45,"target":28,"value":2},{"source":47,"target":46,"value":1},{"source":48,"target":47,"value":2},{"source":48,"target":25,"value":1},{"source":48,"target":27,"value":1},{"source":48,"target":11,"value":1},{"source":49,"target":26,"value":3},{"source":49,"target":11,"value":2},{"source":50,"target":49,"value":1},{"source":50,"target":24,"value":1},{"source":51,"target":49,"value":9},{"source":51,"target":26,"value":2},{"source":51,"target":11,"value":2},{"source":52,"target":51,"value":1},{"source":52,"target":39,"value":1},{"source":53,"target":51,"value":1},{"source":54,"target":51,"value":2},{"source":54,"target":49,"value":1},{"source":54,"target":26,"value":1},{"source":55,"target":51,"value":6},{"source":55,"target":49,"value":12},{"source":55,"target":39,"value":1},{"source":55,"target":54,"value":1},{"source":55,"target":26,"value":21},{"source":55,"target":11,"value":19},{"source":55,"target":16,"value":1},{"source":55,"target":25,"value":2},{"source":55,"target":41,"value":5},{"source":55,"target":48,"value":4},{"source":56,"target":49,"value":1},{"source":56,"target":55,"value":1},{"source":57,"target":55,"value":1},{"source":57,"target":41,"value":1},{"source":57,"target":48,"value":1},{"source":58,"target":55,"value":7},{"source":58,"target":48,"value":7},{"source":58,"target":27,"value":6},{"source":58,"target":57,"value":1},{"source":58,"target":11,"value":4},{"source":59,"target":58,"value":15},{"source":59,"target":55,"value":5},{"source":59,"target":48,"value":6},{"source":59,"target":57,"value":2},{"source":60,"target":48,"value":1},{"source":60,"target":58,"value":4},{"source":60,"target":59,"value":2},{"source":61,"target":48,"value":2},{"source":61,"target":58,"value":6},{"source":61,"target":60,"value":2},{"source":61,"target":59,"value":5},{"source":61,"target":57,"value":1},{"source":61,"target":55,"value":1},{"source":62,"target":55,"value":9},{"source":62,"target":58,"value":17},{"source":62,"target":59,"value":13},{"source":62,"target":48,"value":7},{"source":62,"target":57,"value":2},{"source":62,"target":41,"value":1},{"source":62,"target":61,"value":6},{"source":62,"target":60,"value":3},{"source":63,"target":59,"value":5},{"source":63,"target":48,"value":5},{"source":63,"target":62,"value":6},{"source":63,"target":57,"value":2},{"source":63,"target":58,"value":4},{"source":63,"target":61,"value":3},{"source":63,"target":60,"value":2},{"source":63,"target":55,"value":1},{"source":64,"target":55,"value":5},{"source":64,"target":62,"value":12},{"source":64,"target":48,"value":5},{"source":64,"target":63,"value":4},{"source":64,"target":58,"value":10},{"source":64,"target":61,"value":6},{"source":64,"target":60,"value":2},{"source":64,"target":59,"value":9},{"source":64,"target":57,"value":1},{"source":64,"target":11,"value":1},{"source":65,"target":63,"value":5},{"source":65,"target":64,"value":7},{"source":65,"target":48,"value":3},{"source":65,"target":62,"value":5},{"source":65,"target":58,"value":5},{"source":65,"target":61,"value":5},{"source":65,"target":60,"value":2},{"source":65,"target":59,"value":5},{"source":65,"target":57,"value":1},{"source":65,"target":55,"value":2},{"source":66,"target":64,"value":3},{"source":66,"target":58,"value":3},{"source":66,"target":59,"value":1},{"source":66,"target":62,"value":2},{"source":66,"target":65,"value":2},{"source":66,"target":48,"value":1},{"source":66,"target":63,"value":1},{"source":66,"target":61,"value":1},{"source":66,"target":60,"value":1},{"source":67,"target":57,"value":3},{"source":68,"target":25,"value":5},{"source":68,"target":11,"value":1},{"source":68,"target":24,"value":1},{"source":68,"target":27,"value":1},{"source":68,"target":48,"value":1},{"source":68,"target":41,"value":1},{"source":69,"target":25,"value":6},{"source":69,"target":68,"value":6},{"source":69,"target":11,"value":1},{"source":69,"target":24,"value":1},{"source":69,"target":27,"value":2},{"source":69,"target":48,"value":1},{"source":69,"target":41,"value":1},{"source":70,"target":25,"value":4},{"source":70,"target":69,"value":4},{"source":70,"target":68,"value":4},{"source":70,"target":11,"value":1},{"source":70,"target":24,"value":1},{"source":70,"target":27,"value":1},{"source":70,"target":41,"value":1},{"source":70,"target":58,"value":1},{"source":71,"target":27,"value":1},{"source":71,"target":69,"value":2},{"source":71,"target":68,"value":2},{"source":71,"target":70,"value":2},{"source":71,"target":11,"value":1},{"source":71,"target":48,"value":1},{"source":71,"target":41,"value":1},{"source":71,"target":25,"value":1},{"source":72,"target":26,"value":2},{"source":72,"target":27,"value":1},{"source":72,"target":11,"value":1},{"source":73,"target":48,"value":2},{"source":74,"target":48,"value":2},{"source":74,"target":73,"value":3},{"source":75,"target":69,"value":3},{"source":75,"target":68,"value":3},{"source":75,"target":25,"value":3},{"source":75,"target":48,"value":1},{"source":75,"target":41,"value":1},{"source":75,"target":70,"value":1},{"source":75,"target":71,"value":1},{"source":76,"target":64,"value":1},{"source":76,"target":65,"value":1},{"source":76,"target":66,"value":1},{"source":76,"target":63,"value":1},{"source":76,"target":62,"value":1},{"source":76,"target":48,"value":1},{"source":76,"target":58,"value":1}]}
  #this is for this d3.js example (http://bl.ocks.org/mbostock/950642#graph.json)
  def printGraphAsJson

    nodeNameToIndexInNodeArr_map = Hash.new
    
    #add nodes
    nodesArr = Array.new
    i = 0
    @nodes.each do |name,weight|
      nodesArr << { "name" => name, "group" => 1 }
      nodeNameToIndexInNodeArr_map[name] = i
      i += 1
    end
    
    #add edges
    linksArr = Array.new
    @weights.each do |node1, node2|
      #e.g. node1 = us senate, node2 = {"budget"=>1.0}=
      linksArr << {"source" => nodeNameToIndexInNodeArr_map[node1], "target" => nodeNameToIndexInNodeArr_map[node2.keys[0]]}
    end
    
    return {"nodes" => nodesArr, "links" => linksArr}.to_json
  end
  
  
  
  
  
  #Mergin Two Graphs
  #For merging graph g2 into graph g1
  #scan all the nodes of g2
  #if a node is common between g1 and g2 e.g. 'commonNode', 
    #merge the entries in g2.graph['commonNode'] with g1.graph['commongNode']:
      #note that g1.graph['node'] contains a list of nodes which have an edge that points to 'node' in g1
      #so to merge, scan the list that is g2.graph['commonNode'], for each node (pointingNode) in this list
        #if pointingNode exists in g1.graph['commonNode'] then g1.weights['pointingNode']['commonNode'] += g2.weights['pointingNode']['commonNode']
        #else g1.graph['commonNode'] << pointingNode and also g1.weights['pointingNode']['commonNode'] = g2.weights['pointingNode']['commonNode']
  #else if the node only exists in g2 i.e. 'g2Node'
    #g1.graph['g2Node] = Array.new
    #g1.geaph['g2Node'] = g2.graph['g2Node']
    
  #normalzie all outgoing edge weights  
  
  
  

  def mergeGraphs( otherGraph )
    # do the two graphs have any common nodes? V
    otherGraph.graph.each do |node_n, nodesPointingToNoden_n|

      #common node
      if self.graph.has_key? node_n
        
        #combine common nodes V
        for nodePointingToNode_n_inOtherGraph in nodesPointingToNoden_n
          
          if self.graph[node_n].include? nodePointingToNode_n_inOtherGraph
            self.weights[nodePointingToNode_n_inOtherGraph][node_n] += otherGraph.weights[nodePointingToNode_n_inOtherGraph][node_n]
          else
            self.graph[node_n] << nodePointingToNode_n_inOtherGraph
            if not self.weights.has_key? nodePointingToNode_n_inOtherGraph
              self.weights[nodePointingToNode_n_inOtherGraph] =  Hash.new
            end
            self.weights[nodePointingToNode_n_inOtherGraph][node_n] = otherGraph.weights[nodePointingToNode_n_inOtherGraph][node_n]
          end
            
        end
        #combine common nodes ^
        
      #not commong node: node that is in the second graph but not the first one
      else
        
        self.graph[node_n] = Array.new
        self.graph[node_n] = otherGraph.graph[node_n]
        #>>>> todo add weights from other graph to this graph
        for nodePointingToNode_n_inOtherGraph in nodesPointingToNoden_n
          if not self.weights.has_key? nodePointingToNode_n_inOtherGraph
            self.weights[nodePointingToNode_n_inOtherGraph] =  Hash.new
          end
          self.weights[nodePointingToNode_n_inOtherGraph][node_n] = otherGraph.weights[nodePointingToNode_n_inOtherGraph][node_n]
        end
        
      end
      
    end
    
    #merge the @nodes. note @nodes is a hash where keys are node names 'terms' and values are weightsr
    otherGraph.nodes.each do |nodeName, weight|
      puts("nodeName = #{nodeName}")
      if self.nodes.has_key? nodeName
        puts("in if nodeName = #{nodeName}")
        self.nodes[nodeName] += weight
      else
        # self.nodes[node] = Hash.new
        puts("in else otherGraph.nodes[node] = #{otherGraph.nodes[nodeName]}")
        self.nodes[nodeName] = weight
      end  
    end
    
    return self
  end

  private

  # Performs one iteration to calculate
  # the PageRank ranking for all nodes.
  def iteration
    #puts('in iteration')
    new_nodes = {}
    @graph.each do |node,links|
      #puts("node= #{node}, links = #{links}")
      
      score = links.map do |id|
        if @doPageRank
          if @normalizeEdgeWeight #< this is my method not striagh pagerank
            #if we've already normalized edge weights there is no need to divide by the number of edges, dividing by the number of edge IS the normalization when all edges have weight 1.
            @nodes[id] * @weights[id][node]
          else
            @nodes[id] / @outlinks[id] * @weights[id][node] #straight pagerank score
          end
        elsif @doGravityRank #do gravityRank
          @nodes[id] * @weights[id][node] #not dividing by out link just like a planet's gravity is the same regardless of how many other planets are around it > note that maxt iter needs to be small for this as it wouldn't converge
        end  
      end.inject(:+)
      
      new_nodes[node] = (1-@damping/
      @nodes.size) + @damping * score
    end
    new_nodes
  end

  # Check for convergence.
  def convergence(current)
    diff = {}
    @nodes.each do |k,v|
      #puts("k = #{k}")      
      diff[k] = current[k] - @nodes[k]
    end
    total = 0.0
    diff.each { |k,v| total += diff[k] * v }
    Math.sqrt(total/current.size) < @convergence
  end

end