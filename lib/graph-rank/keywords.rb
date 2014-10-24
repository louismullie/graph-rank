# Implement the PageRank algorithm
# for unsupervised keyword extraction.

require 'engtagger'

class GraphRank::Keywords < GraphRank::TextRank
    
  attr_accessor :hulth1939

  
  def initialize
      #text of abstract 1939 in test set of hulth dataset used as example in textrank paper
      @hulth1939 = "Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types"
      
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