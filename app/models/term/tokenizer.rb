class Term::Tokenizer
  attr_reader :text

  STOPWORDS = Set.new(%w[a an and are as at be by for from has he in is it its of on that the to was were will with])

  def initialize(text)
    @text = text
  end

  def tokenize
    words = text.downcase.scan(/\w+/)
    words.reject! { |word| STOPWORDS.include?(word) }
    words.map { |word| stem(word) }
  end

  private

  def stem(word)
    # Basic stemming: remove common suffixes
    word.gsub(/(ing|ed|ly|es|s)$/, "")
  end
end
