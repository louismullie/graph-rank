# Brin, S.; Page, L. (1998). "The anatomy of 
# a large-scale hypertextual Web search engine". 
# Computer Networks and ISDN Systems 30: 107–117.
class GraphRank::PageRank

  # Initialize with default damping and convergence.
  # A maximum number of iterations can also be supplied
  # (default is no maximum, i.e. iterate until convergence).
  def initialize(damping=nil, convergence=nil, max_it=-1)
    damping ||= 0.85; convergence ||= 0.01
    if damping <= 0 or damping > 1
      raise 'Invalid damping factor.'
    elsif convergence < 0 or convergence > 1
      raise 'Invalid convergence factor.'
    end
    @damping, @convergence, @max_it = damping, convergence, max_it
    @graph, @outlinks, @nodes, @weights = {}, {}, {}, {}
  end

  # Add a node to the graph.
  def add(source, dest, weight=1.0)
    return false if source == dest
    @outlinks[source] ||= 0.0
    @graph[dest] ||= []
    @graph[dest] << source
    @outlinks[source] += 1.0
    @nodes[source] = 0.15
    @nodes[dest] = 0.15
    @weights[source] ||= {}
    @weights[source][dest] = weight
  end

  # Iterates the PageRank algorithm
  # until convergence is reached.
  def calculate
    done = false
    until done
      break if @max_it == 0
      new_nodes = iteration
      done = convergence(new_nodes)
      @nodes = new_nodes
      @max_it -= 1
    end
    @nodes.sort_by {|k,v|v}.reverse
  end

  private

  # Performs one iteration to calculate
  # the PageRank ranking for all nodes.
  def iteration
    new_nodes = {}
    @graph.each do |node,links|
      score = links.map do |id|
        @nodes[id] / @outlinks[id] * @weights[id][node]
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
      diff[k] = current[k] - @nodes[k]
    end
    total = 0.0
    diff.each { |k,v| total += diff[k] * v }
    Math.sqrt(total/current.size) < @convergence
  end

end