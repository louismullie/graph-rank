# Implement the PageRank algorithm
# for unsupervised keyword extraction.

#HOW TO RUN
#if you wanna update and reload the files inside graph-rank folder you can go to graph-rank folder then do 
#load '../graph-rank.rb' #load from the parent dir
#for some reason have to do a load './keywords.rb' for my changes in the file to take effect
#now you can do
#tr = GraphRank::Keywords.new
#tr.run(someInputText).inspect or tr.run(tr.hulth1939).inspect
# and if you make changes the load './whateverfileInGraph-rankFoler.rb'

require 'engtagger'

class GraphRank::Keywords < GraphRank::TextRank
    
  attr_accessor :hulth1939
  attr_accessor :stop_words

  
  def initialize()
      puts('we hea')
      
      #text of abstract 1939 in test set of hulth dataset used as example in textrank paper
      @hulth1939 = "Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types"
      
      super()
      
  end
  
    # combines adjacent high ranking words into multi words
    #input: takes the output of the textrank.run function
    def combineAdjacent wordRankings
        wordRankings = wordRankings.to_h
        text = clean_text
        combinedCandidates = Hash.new
        candidate = ""
        weight = 0
        for word in text.split " "
            if wordRankings.has_key? word
                candidate = candidate + " " + word
                weight = weight + wordRankings[word]
            else
                if weight != 0 and candidate != ""
                    candidate = candidate.strip
                    combinedCandidates[candidate] = weight
                end
                candidate = ""
                weight = 0
            end
        end 
        return combinedCandidates
    end
    
    def post_process ranking
        combineAdjacent ranking
    end
      

  # Split the text on words.
  def get_features
    clean_text
    @features = @text.split(' ')
  end

  # Remove short and stop words.
  def filter_features
    
    ### POS TAG FILTER ###
    @tgr = EngTagger.new
    tagged = @tgr.add_tags(@text)
    nouns = @tgr.get_nouns(tagged)
    adjs = @tgr.get_adjectives(tagged)      
    nounsnadjs = nouns.merge(adjs)
    puts("nounsnadjs = #{nounsnadjs}")
    @features.delete_if { |word| not nounsnadjs.has_key?(word) }
    ### POS TAG FILTER ###    
    
    remove_short_words
    remove_stop_words
  end

  # Clean text leaving just letters from a-z.
  def clean_text
    @text.downcase!
    @text.gsub!(/[^a-z ]/, ' ')
    @text.gsub!(/\s+/, " ")
  end

  # Remove all stop words.
  def remove_stop_words
    @features.delete_if { |word| @stop_words.include?(word) }
  end

  # Remove 1 and 2 char words.
  def remove_short_words
    @features.delete_if { |word| word.length < 3 }
  end

  # Build the co-occurence graph for an n-gram.
  def build_graph
    @features.each_with_index do |f,i|
      min, max = i - @ngram_size, i + @ngram_size
      while min < max
        if @features[min] and min != i
          @ranking.add(@features[i], @features[min])
        end
        min += 1
      end
    end
  end

end