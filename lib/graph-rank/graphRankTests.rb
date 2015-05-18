require 'graph-rank'

class GraphRankTests
  
  def combineGraphsDetectsCommonNodes
    gr1 = GraphRank::PageRank.new
    gr2 = GraphRank::PageRank.new
    
    #build up a smaple graph. all edges are bidirectional as it will be when building text graphs, soheil may 15 2015, started work on combining graphs
    #for gr1
    gr1.add("us senate", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr1.add("budget", "us senate", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr1.add("obama", "house", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr1.add("house", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr1.add("obama", "budget", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr1.add("budget", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr1.add("obama", "election", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr1.add("election", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    #for gr2
    gr2.add("obama", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr2.add("foreing policy", "obama", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr2.add("dollar", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr2.add("foreing policy", "dollar", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr2.add("oil", "foreing policy", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    gr2.add("foreing policy", "oil", weight=1.0, sourcePriorWeight = 0.15, destPriorWeight = 0.15)
    
    gr = gr1.combineGraphs(gr2)
  end
  
end