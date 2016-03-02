# Implement the PageRank algorithm
# for unsupervised keyword extraction.

#TODO investigate changing the cam gem file so bundle install knows which github repo (i.e. mine) to grab this gem from, that way we have the options of actually getting the gem if I move to a new machine or generally in addition to building it lcoally
#HOW TO BUILD GEM
#in outer graph-rank dir
#gem build graph-rank.gemspec
#gem install ./graph-rank.<version>.gem e.g. gem install ./graph-rank-0.0.3.gem

#HOW TO RUN
#if you wanna update and reload the files inside graph-rank folder you can go to the inner graph-rank folder (e.g. /Users/soheil.danesh/GitHub/graph-rank/lib/graph-rank) then do 
#load '../graph-rank.rb' #load from the parent dir
#for some reason have to do a load './keywords.rb' for my changes in the file to take effect
#now you can do
#tr = GraphRank::Keywords.new
#tr.run(someInputText).inspect e.g. :
# text = String.new(tr.hulth1939)
#tr.run(text).inspect
# and if you make changes then load './whateverfileInGraph-rankFolder.rb'
  
require 'engtagger'
require 'stopwords'

require 'net/http'
require 'json'


class GraphRank::Keywords < GraphRank::TextRank
    
  attr_accessor :hulth1939, :stop_words, :text
  

  
  def initialize()
      #text of abstract 1939 in test set of hulth dataset used as example in textrank paper
      @hulth1939 = "Compatibility of systems of linear constraints over the set of natural numbers Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered. Upper bounds for components of a minimal set of solutions and algorithms of construction of minimal generating sets of solutions for all types of systems are given. These criteria and the corresponding algorithms for constructing a minimal supporting set of solutions can be used in solving all the considered types of systems and systems of mixed types"
      @websimAlreadyCalulated = Hash.new
  
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
  
  #calcualtes semantic similarity between two phrases using www stats
  def calcWebSeimilarity term1, term2
    if @websimAlreadyCalulated.has_key?(term1+"|"+term2)
      return @websimAlreadyCalulated[term1+"|"+term2]
    elsif @websimAlreadyCalulated.has_key?(term2+"|"+term1)
      return @websimAlreadyCalulated[term2+"|"+term1]
    end
    
    if true
      #using GOOGLE SEARCH##3
      googleCustomSearch = "https://www.googleapis.com/customsearch/v1?key=AIzaSyAyG411hP82joew7H6eS7BkOlYRmnzhcsQ&cx=018143346535097940560:ajfearh_lmu&q="
      uriBoth = URI(URI.escape(googleCustomSearch + term1 + " " + term2))
      uri1 = URI(URI.escape(googleCustomSearch+term1))
      uri2 = URI(URI.escape(googleCustomSearch+term2))
      #using GOOGLE SEARCH##3
      
      numContainBoth = JSON.parse(Net::HTTP.get(uriBoth))["searchInformation"]["totalResults"]
      numContain1 = JSON.parse(Net::HTTP.get(uri1))["searchInformation"]["totalResults"]
      numContain2 = JSON.parse(Net::HTTP.get(uri2))["searchInformation"]["totalResults"]
    end
    
    if false
      #using sindice
      query = term1+" "+term2
      sindice = "http://api.sindice.com/v3/search?q=#{query}&format=json"
      uriBoth = URI(URI.escape(sindice))
    
      query = term1
      sindice = "http://api.sindice.com/v3/search?q=#{query}&format=json"
      uri1 = URI(URI.escape(sindice))
    
      query = term2
      sindice = "http://api.sindice.com/v3/search?q=#{query}&format=json"
      uri2 = URI(URI.escape(sindice))
      
      numContainBoth = JSON.parse(Net::HTTP.get(uriBoth))["totalResults"]
      numContain1 = JSON.parse(Net::HTTP.get(uri1))["totalResults"]
      numContain2 = JSON.parse(Net::HTTP.get(uri2))["totalResults"]
    end
    
    puts("uriBoth = #{uriBoth} ")
    puts("web response in webSim = #{Net::HTTP.get(uriBoth)}")
    
    #using sindice

    
    #for now, [ ] experiment with other measures 
    puts("terms = #{term1} and #{term2}, numContainBoth = #{numContainBoth}, numContain1 = #{numContain1} numContain2 = #{numContain2}")
    @logFile.puts("in calcWebSeimilarity numContainBoth = #{numContainBoth}, numContain1 = #{numContain1} numContain2 = #{numContain2}")
    jaccard = Float(numContainBoth)/Float(numContain1+numContain2)
    return jaccard
  end
  
  def build_graph_web_sim phraseWeights, logFile
    puts("in build_graph_web_sim ")
    @logFile = logFile
    
    #BUILD GRAPH
    for pw in phraseWeights
      for pw2 in phraseWeights
        #SKIP NEGATIVE WEIGHTS OR IF WORDS ARE THE SAME
        if pw['weight'] <= 0 or pw2['weight'] <=0 or pw['word'].strip == pw2['word'].strip
          next
        end
        
        webSim = calcWebSeimilarity(pw["word"], pw2["word"])
        @websimAlreadyCalulated[pw["word"]+"|"+pw2["word"]] = webSim

        logFile.puts("webSim for #{pw["word"]} and #{pw2["word"]} = #{webSim}")
        
        @ranking.add(pw["word"], pw2["word"], pw['weight'] * pw2['weight'] * webSim )
      end    
    end
    #BUILD GRAPH
    
    return @ranking.calculate
  end

  
  #graph where individual occurrences of words are nodes
  #note, weights have to be normalized (i.e. smaller than 1) or it wouldn't coverge
  def build_graph_cam phraseWeights, ngramPositions, idfHash, docLength, logFile
    puts("in build_graph_cam ")
    
    #flag
    wrapText = false #[ ]todo get this working
    if wrapText
      logFile.puts('wrapping text in build_graph_cam')
    end
    
    #BUILD GRAPH
    for pw in phraseWeights
      for pw2 in phraseWeights
        
        #SKIP NEGATIVE WEIGHTS OR IF WORDS ARE THE SAME
        if pw['weight'] <= 0 or pw2['weight'] <=0 or pw['word'] == pw2['word']# optional: we check agains putting an edge between something and itself using positions so don't need this: or pw['word'] == pw2['word']
          next
        end
        
        pwPositions = ngramPositions[pw['word']]    
        pw2Positions = ngramPositions[pw2['word']]

        for pos in pwPositions
          for pos2 in pw2Positions
            
            
            #flag
            connectToWithinWindowOnly = false #todo try it
            if connectToWithinWindowOnly
              if (pos - pos2).abs > 200
                next
              end
            end
              
            
            #WRAP TEXT AND CALC SHORTER DISTANCE
            #wrapping text in circle and taking the shorter path around circle between two terms as the distance
            if wrapText
              if (pos - pos2).abs > Float(docLength)/2.0
                if pos > pos2
                  pos = (docLength - pos) + pos2
                elsif pos2 > pos
                  pos2 = (docLength - pos2) + pos
                end
              end
            end
            #WRAP TEXT AND CALC SHORTER DISTANCE
            
            #check to see if your are not placing an edge from word withing the ngram to the ngram (which would have inifinite weight and is just conceptually wrong)
            if pos < pos2 and pos+pw['word'].split.size > pos2
              next
            elsif pos2 < pos and pos2+pw2['word'].split.size > pos
              next
            elsif pos == pos2
              next
            end
            
            if false
              #used this as numerator here and it underperfed bad ie it was edgew/(pos-pos2).abs
              if(idfHash[pw2['word']] >= idfHash[pw['word']])
                edgew = 1.0
              else
                edgew = idfHash[pw2['word']] / idfHash[pw['word']]
              end
            end 
            #old edge weight numerator ((pw['weight']+pw2['weight'])/2)
            #(idfHash[pw2['word']] / (idfHash[pw2['word']] + idfHash[pw['word']]))  this was numerator too and it underperfed
            if docLength < 3500
              docLength = 3500
            end
            positionFactor = - 1.0 * Math.log(Float(pos+pos2)/2.0 / Float(docLength))
            maxNgramLength = 6.0
            termLengthFactor = Float(pw['word'].split.size + pw2['word'].split.size) / 2.0 / maxNgramLength
            
            #this is the version where term weights are factored into edge weights, it's underperfing slighly
            #@ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']*pw2['weight']) * positionFactor * termLengthFactor / Float((pos-pos2)).abs ** 2) #experimenting with power of two here
          
            #flag
            noPositionFactor = true
            
            if noPositionFactor
              #Best So Far .1 improve over 5 gram best baseline >> @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']*pw2['weight']) / Float((pos-pos2).abs), pw['weight'], pw2['weight'])
              # no go >> @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", 1.0 / Float((pos-pos2).abs), pw['weight'], pw2['weight']) #try without wordWeights in edges, just distance
              
              #log decay the distance 
              logDist = Math.log(1500.0 / Float((pos-pos2).abs))
              if logDist <= 0
                next
              end  
              @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']*pw2['weight']) * logDist , pw['weight'], pw2['weight'])
              # underperfs with no product of weights in edge : @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", logDist , pw['weight'], pw2['weight'])
            else
              @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']*pw2['weight']) * positionFactor  / Float((pos-pos2).abs), pw['weight'], pw2['weight'])
              
              
            end
              
            
            if false #[ ]todo try this
              #reward a word for occuring in the vicinity of itself
              if pw['word'] == pw2['word'] and (pos-pos2).abs < 200
                @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']) * positionFactor  / Float((pos-pos2).abs), pw['weight'], pw2['weight'])
              else
                #this is the version where edge weights are based on average position of terms from document start and their distance and term weights are passed in as initial weights of each node
                @ranking.add( "#{pw['word']}__#{pos}", "#{pw2['word']}__#{pos2}", (pw['weight']*pw2['weight']) * positionFactor  / Float((pos-pos2).abs), pw['weight'], pw2['weight'])
              end
            end
          end
        end
        
      end
    end
    #BUILD GRAPH
    
    
    #@ranking.printGraph nil, logFile #for debug
    puts('graph is built in build_graph_cam, going to calculate pagerank')
    
    result = @ranking.calculate
    return result
    
   
  end

  #input is an array consisting of phrases and their weights [{"word" => phrase, "weight" => itsWeight}]
  #this method build a graph that will be used to rerank them. termFreq and idf arguments passed in determine the weighting scheme (if one nil the other is used, if both not nil tf.idf is used)
  #option one: place links between terms that have one word in common
  def build_rerank_graph phraseWeights,  ngramPositions, options
    puts("in build_rerenk_graph. working on personalized pagerank branch")
    

    @logFile = options['logFile']
    windowSize = options['windowSize'] || 1500
    pprVector = options['pprVector'] || []

    #only of of these should be true
    textRankStyleEdgeWeighting = false
    doTopicRankDist = false
    doLogDist = true

    for pw in phraseWeights
      for pw2 in phraseWeights
        if pw['weight'] <= 0 or pw2['weight'] <=0 
          next
        end
        
        weight = 0.0
        
        # shouldn't we skip placing edge between the term and itself?
        if pw['word'] == pw2['word'] 
          next # though we never seem to hit this - not sure what's going on here.
        end
        
        #calculate the number of times these phrases occur within a certain didstance d
        if not ngramPositions.nil?
          #PHRASE COOC COUNT EDGE WEIGHTING
          d = windowSize
          numCoocs = 0
          
          pwPositions = ngramPositions[pw['word']]    
          pw2Positions = ngramPositions[pw2['word']]
          

          topicRankDist = 0.0
          numTopicRankDists = 0.0
          
          logDistSum = 0.0
          numLogDistCoocs = 0.0
          
          # V CALCUALTE EDGE WEIGHT BETWEEN TWO TERMS BASED ON THEIR POSITIONS OF OCCURENCE AND THEIR DISTANCES
          for pos in pwPositions
            for pos2 in pw2Positions

              #check to see if your are not counting a cooc with a word within the ngram
              if pos < pos2 and pos+pw['word'].split.size > pos2
                next
              elsif pos2 < pos and pos2+pw2['word'].split.size > pos
                next
              elsif pos == pos2
                next
              end
              #check to see if your are not counting a cooc with a word withing the ngram
              
              if pos < pos2 and pos+pw['word'].split.size < pos2 and pos2 < pos+pw['word'].split.size+d
                  numCoocs = numCoocs + 1
              elsif pos2 < pos and pos2+pw2['word'].split.size < pos and pos < pos2+pw2['word'].split.size+d
                  numCoocs = numCoocs + 1
              elsif pos == pos2
                next
              end


              #DOING CALCULATIONS FOR DIFFERENT EDGE WEIGHTING STRATEGIES#
              if textRankStyleEdgeWeighting and (pos - pos2).abs < 100
                numCoocs = numCoocs + 1
              end
              
              if doTopicRankDist
                if (pos - pos2).abs < windowSize #otherwise it remains zero
                  numTopicRankDists += 1
                  ###CALC DISTANCE TOPICRANK WAY###
                  topicRankDist = topicRankDist +  1.0 / (pos - pos2).abs
                  ###CALC DISTANCE TOPICRANK WAY###
                end
              end
              
              #flag
              
              if doLogDist
                ### CALC DISTANCE USING MY LOGDIST WAY THAT SHOWS POSITIVE RESULTS IN build_graph_cam
                windowSize = 1500
                
                if (pos-pos2).abs < windowSize
                  logDistSum = logDistSum +  Math.log(windowSize / Float((pos-pos2).abs))
                  numLogDistCoocs += 1
                end
                ### CALC DISTANCE USING MY LOGDIST WAY THAT SHOWS POSITIVE RESULTS IN build_graph_cam
              end
              #DOING CALCULATIONS FOR DIFFERENT EDGE WEIGHTING STRATEGIES#

            end
          end
          # ^ CALCUALTE EDGE WEIGHT BETWEEN TWO TERMS BASED ON THEIR POSITIONS OF OCCURENCE AND THEIR DISTANCES
          
          #NORMAL CASE - USING LOG DIST EDGE WEIGHTING
          if doLogDist
            weight = Float(logDistSum) / Float(numLogDistCoocs)  
          end
          
          #USING TextRank style edge weighting : if weighting edges simply by num coocs - not taking into account distance of co-occurrence
          if textRankStyleEdgeWeighting and false #for now not forseeing using this, only for comparison later on
            #straight num cooks
            weight = Float(numCoocs) / 100
          end
          
          #USING TOPIC RANK DIST EDGE WEIGHTING
          if doTopicRankDist and false #for now not forseeing using this, only for comparison later on
            #take average
            weight =  Float(topicRankDist) / Float(numTopicRankDists)
          end
          
        end
        

        # V add edge to graph
        if weight > 0  

          if false and  weight > 1
            weight = 1
          end
          
          #Not adding initial word weights, for measurement purposes of effectiveness of feature
          @ranking.add(pw["word"], pw2["word"], weight * (pw['weight']*pw2['weight']))

        end
        # ^ add edge to graph
        
      end
    end

    #add personalized pageRank edges
    #note: pprVector is execpted to be of format [{"word" => "someWord", "weight" => 0.56}, ...]
    #each edge goes from a regular node a to node in a passed in ppr vector
    #it is generally assumed that terms in the ppr are a subset of those in the phraseWeights (which are all the word/wight tuples the graph will be built out of)
    #therefore check before adding nodes from ppr vector to make sure they exist in the phraseWeights, the term only
    #for each term in the ppr vector then, add an edge from each of the graph nodes to it, the weight of this edge  
    # V Personalized PageRank - create edges from each node to nodes in the personalized page rank vector
    if not pprVector.empty?
      pprVector.each do |termWeightTuple|
        for pw in phraseWeights
          @ranking.add(pw['word'], termWeightTuple['word'], termWeightTuple['weight'])
        end
      end
    end
    # ^ Personalized PageRank - create edges from each node to nodes in the personalized page rank vector

    log("textRerank graph = #{@ranking.printGraph}")
    puts("just camed the graph, going to calculate ...")
    result = @ranking.calculate
    return {rankedTermsList: result, graph: @ranking}
  end

  def log msg
    if @logFile
      @logFile.puts(msg)
    end
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
    
    #@ranking.printGraph
  end

end