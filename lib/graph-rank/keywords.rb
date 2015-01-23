# Implement the PageRank algorithm
# for unsupervised keyword extraction.

#HOW TO BUILD GEM
#in outer graph-rank dir
#gem build graph-rank.gemspec
#gem install ./graph-rank.<version>.gem

#HOW TO RUN
#if you wanna update and reload the files inside graph-rank folder you can go to graph-rank folder then do 
#load '../graph-rank.rb' #load from the parent dir
#for some reason have to do a load './keywords.rb' for my changes in the file to take effect
#now you can do
#tr = GraphRank::Keywords.new
#tr.run(someInputText).inspect e.g. :
# text = String.new(tr.hulth1939)
#tr.run(text).inspect
# and if you make changes the load './whateverfileInGraph-rankFoler.rb'

require 'engtagger'
require 'stopwords'

class GraphRank::Keywords < GraphRank::TextRank
    
  attr_accessor :hulth1939, :stop_words, :text

  
  def initialize()
      #text of abstract 1939 in test set of hulth dataset used as example in textrank paper
      @hulth1939 = "Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types"
      
      super()
      
  end
  
    # combines adjacent high ranking words into multi words
    #input: takes the output of the textrank.run function
    #Output: produces a list of combined and single words, the weight of combined words is the sum of weights of single words comprising it, returns the top 1/3*NumberOfVertices (i.e. single words passed in) of combined and single words list 
    def combineAdjacent wordRankings
        
        #TAKE TOP 1/T words
        wordRankings = wordRankings#.slice(0..wordRankings.size/3) #ATTENTION: if you uncomment this comment out bottom ".slice(0..wordRankings.size/3)"
        #TAKE TOP 1/T words
        
        wordRankings = wordRankings.to_h
        
        #puts("top words = #{wordRankings}")
        combinedCandidates = Hash.new
        candidate = ""
        weight = 0
        
        text = @text.gsub(/[^a-z|-| ]/, ' * ')
        text = text.gsub!(/\s+/, " ").strip #multi spaces into 1

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
        
        comCandsPuncsElimed = Hash.new
        ## ELIMINATE CANDIDATES WITH PUNCS IN MIDDLE ##
        combinedCandidates.each do |cand, weight|
            if @text.include? cand
                comCandsPuncsElimed[cand] = weight
            else
                puts "eliminating #{cand} as it has non char in middle"
            end
        end
         
        ## ELIMINATE CANDIDATES WITH PUNCS IN MIDDLE ##
        
        
        ## ELIMINATE  PUNCTUATIONS FROM CANDIDATES ##
        if false
            combinedCandidates.each do |cand, weight|
                #replace all non letter chars with start
                cand = cand.gsub(/[^a-z ]/, '*')
            
                #cands = cand.split('*')
                #for cand in cands 
                #    comCandsPuncsElimed[cand] = weight
                #end


                if false and cand.include? '*'
                
                    # TAKE CARE OF PUNCS NOT IN MIDDLE #
                    if(cand[0] == '*')
                        cand[0] = ''
                    end
                    if(cand[cand.size-1] == '*')
                        cand[cand.size-1] = ''
                    end
                    # TAKE CARE OF PUNCS NOT IN MIDDLE #
                
                    if cand.include? '*'
                        #skip inclusion in final candidate list
                    else
                        #this is case where puncs were not in middle
                        comCandsPuncsElimed[cand] = weight
                    end
                else
                   comCandsPuncsElimed[cand] = weight 
                end
            end
        end
        
        ## ELIMINATE  PUNCTUATIONS FROM CANDIDATES ##

        return comCandsPuncsElimed.sort_by {|k,v|v}.reverse#.slice(0..wordRankings.size/3) #it's eithr this or the "TAKE TOP 1/T words" above
    end
    
    def post_process ranking
        combineAdjacent ranking
    end
      

  # Split the text on words.
  def get_features
    text = clean_text @text
    @features = text.split(' ')
  end

  # Remove short and stop words.
  def filter_features
    
    ### POS TAG FILTER ###
    @tgr = EngTagger.new
    tagged = @tgr.add_tags(@text)
    nouns = @tgr.get_nouns(tagged)
    adjs = @tgr.get_adjectives(tagged)
    verbs = get_verbs(tagged)      

    nounsnadjs = nouns.merge(adjs)
    nounsAdjsVerbs = nounsnadjs.merge(verbs)

    #filter anything except for nouns and adjectives (for hulth dataset)
    @features.delete_if { |word| not nounsnadjs.has_key?(word) }
    
    #filter anything except for nouns and adjectives and verbs (for semeval dataset)
    #@features.delete_if { |word| not nounsAdjsVerbs.has_key?(word)  }
    
    
    
    
    ### POS TAG FILTER ###    
    
    #remove_short_words
    #remove_stop_words
  end
  
  #return just the tags for a text
  def get_verbs(tagged)
      verbs = Hash.new
      infVerbs = @tgr.get_infinitive_verbs(tagged)
      pastVerbs = @tgr.get_past_tense_verbs(tagged)
      gerVerbs = @tgr.get_gerund_verbs(tagged)
      passVerbs = @tgr.get_passive_verbs(tagged)
      basePresVerbs = @tgr.get_base_present_verbs(tagged)
      
      verbs = infVerbs.merge(pastVerbs).merge(gerVerbs).merge(passVerbs).merge(basePresVerbs)
  end


  # Clean text leaving just letters from a-z.
  def clean_text text
    text = String.new(text)
    text = text.downcase
    text.gsub!(/[^a-z|-| ]/, ' ')
    text.gsub!(/\s+/, " ")
  end

  # Remove all stop words.
  def remove_stop_words
    @features.delete_if { |word| @stop_words.include?(word) }
  end

  # Remove 1 and 2 char words.
  def remove_short_words
    @features.delete_if { |word| word.length < 3 }
  end

  #input is an array consisting of phrases and their weights [{"word" => phrase, "weight" => itsWeight}]
  #this method build a graph that will be used to rerank them
  #option one: place links between terms that have one word in common
  def build_rerank_graph phraseWeights, termFreq
    
    #option one
    for pw in phraseWeights
      weight = 0.0
      for pw2 in phraseWeights
        for token in pw['word'].split(/ |-/)
          for token2 in pw2['word'].split(/ |-/)
            if token == token2
              weight = weight + 1.0 / Float(termFreq[token] + termFreq[token2])
            end
          end
        end
        if weight > 0
          @ranking.add(words[i], words[j])
        end
      end
    end
    puts("in build_rerenk_graph")
    @ranking.printGraph
  end
  
  # Build the co-occurence graph for an n-gram.
  def build_graph
      text = @text.gsub(/[^a-z|-| ]/, ' * ')
      text = text.gsub!(/\s+/, " ").strip.downcase #multi spaces into 1
      


      
      words = text.split " "
      words.delete_if {|word| Stopwords.is? word }
      
      windowLength = @ngram_size 
      words.each_with_index do |word, i|
          puts("i = #{i}, word = #{word}")
          if(@features.include? words[i])
              for j in (i+1..i+windowLength)
                  puts(" j = #{j}, word = #{words[j]}")
                  if j < words.size and @features.include? words[j]
                      puts("connecting #{words[i]}")
                      @ranking.add(words[i], words[j])
                      @ranking.add(words[j], words[i])
                  end
              end
          end
      end
    
    @ranking.printGraph
  end

end