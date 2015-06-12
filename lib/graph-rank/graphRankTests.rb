#how to run: irb > load './graphRankTests.rb' > 

require 'graph-rank'
require 'byebug'

class GraphRankTests

  def initialize()
    @outputFile = File.open("/Users/soheil.danesh/Documents/PROJECTS/cam/visualization/runLogs/graphRankTests_outputFile_#{Time.now.to_s.gsub(':','-')}.txt", 'w+')
  end
  
  def setup
      @gr1 = GraphRank::PageRank.new
      @gr2 = GraphRank::PageRank.new
      @gr3 = GraphRank::PageRank.new

      @gr1.add("us senate", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("budget", "us senate", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "house", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("house", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("budget", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "election", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("election", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      #for @gr2
      @gr2.add("obama", "foreign policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreign policy", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr2.add("dollar", "foreign policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreign policy", "dollar", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr2.add("oil", "foreign policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreign policy", "oil", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      
      #for @gr3 , adding two graphs with the some edge overal e.g. both have obama <-> foreign policy, and oil <-> foreign policy
      @gr3.add("obama", "foreign policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr3.add("foreign policy", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr3.add("obama", "oil", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr3.add("oil", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr3.add("oil", "foreign policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr3.add("foreign policy", "oil", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
  end
  
  def wrapup
    @outputFile.flush
  end
  
  def mergeGraphsTest
    @outputFile.puts("in combineGraphsTest")
    setup
    
    #@gr1.mergeGraphs(@gr2)
    puts("gr1 merged with gr 2 = #{@gr1.printGraphAsJson}")
    @outputFile.puts("@gr1.printGraphAsJson after merging with @gr2 = #{@gr1.printGraphAsJson}")
    
    if(@gr1.printGraphAsJson == '{"nodes":[{"name":"us senate","group":1},{"name":"budget","group":1},{"name":"obama","group":1},{"name":"house","group":1},{"name":"election","group":1},{"name":"foreign policy","group":1},{"name":"dollar","group":1},{"name":"oil","group":1}],"links":[{"source":0,"target":1},{"source":1,"target":0},{"source":2,"target":3},{"source":3,"target":2},{"source":4,"target":2},{"source":6,"target":5},{"source":7,"target":5},{"source":5,"target":2}]}')
      puts("mergeGraphsTest gr1.merge(gr2) SUCCESS")
    else
      puts("mergeGraphsTest gr1.merge(gr2) FAILURE")
    end
    
    @gr1.mergeGraphs(@gr3)
    puts("@gr1.printGraphAsJson after merging with @gr3 = #{@gr1.printGraphAsJson}")
    @outputFile.puts("@gr1.printGraphAsJson after merging with @gr3 = #{@gr1.printGraphAsJson}")
    
    
    wrapup
  end
  
  def printGraphAsJsonTest
    setup
    
    puts("printGraphAsJsonTest")
    puts(@gr3.printGraphAsJson)
    
    if not (@gr1.printGraphAsJson == '{"nodes":[{"name":"us senate","group":1},{"name":"budget","group":1},{"name":"obama","group":1},{"name":"house","group":1},{"name":"election","group":1}],"links":[{"source":0,"target":1},{"source":1,"target":0},{"source":2,"target":3},{"source":3,"target":2},{"source":4,"target":2}]}')
      puts(" printGraphAsJsonTest FAILUERE")
    else
      puts(" printGraphAsJsonTest SUCCESS")
    end
    
    wrapup

  end
  
end