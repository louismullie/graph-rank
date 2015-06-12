#how to run: irb > load './graphRankTests.rb' > 

require 'graph-rank'

class GraphRankTests

  def initialize()
    @outputFile = File.open("/Users/soheil.danesh/Documents/PROJECTS/cam/visualization/graphRankTests_outputFile_#{Time.now.to_s.gsub(':','-')}.txt", 'w+')
  end
  
  def setup
      @gr1 = GraphRank::PageRank.new
      @gr2 = GraphRank::PageRank.new

      @gr1.add("us senate", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("budget", "us senate", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "house", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("house", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("budget", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr1.add("obama", "election", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr1.add("election", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      #for @gr2
      @gr2.add("obama", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreing policy", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr2.add("dollar", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreing policy", "dollar", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)

      @gr2.add("oil", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
      @gr2.add("foreing policy", "oil", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
  end
  
  def wrapup
    @outputFile.flush
  end
  
  def mergeGraphsTest
    @outputFile.puts("in combineGraphsTest")
    setup
    
    @gr1.mergeGraphs(@gr2)
    @outputFile.puts("@gr1.printGraphAsJson = #{@gr1.printGraphAsJson}")
    puts(@gr1.printGraphAsJson)
    
    wrapup
  end
  
  def printGraphAsJsonTest
    setup
    
    puts("printGraphAsJsonTest")
    puts(@gr1.printGraphAsJson)
    
    if not (@gr1.printGraphAsJson == '{"nodes":[{"name":"us senate","group":1},{"name":"budget","group":1},{"name":"obama","group":1},{"name":"house","group":1},{"name":"election","group":1}],"links":[{"source":0,"target":1},{"source":1,"target":0},{"source":2,"target":3},{"source":3,"target":2},{"source":4,"target":2}]}')
      puts(" printGraphAsJsonTest FAILUERE")
    else
      puts(" printGraphAsJsonTest SUCCESS")
    end
    
    wrapup

  end
  
end