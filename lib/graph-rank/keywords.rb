# Implement the PageRank algorithm
# for unsupervised keyword extraction.
class GraphRank::Keywords < GraphRank::TextRank

  # Split the text on words.
  def get_features
    clean_text
    @features = @text.split(' ')
  end

  # Remove short and stop words.
  def filter_features
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