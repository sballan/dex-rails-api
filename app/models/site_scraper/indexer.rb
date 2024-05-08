class SiteScraper::Indexer
  class IndexerError < StandardError
  end

  class PermanentFailure < IndexerError
  end

  class TemporaryFailure < IndexerError
  end

  attr_reader :page, :words, :parser

  def initialize(page, input_string, parser)
    @page = page
    @parser = parser
    @words = sanitize_query_text(input_string)
  end

  def index
    return if words.blank?

    Rails.logger.debug "Starting IndexPage for Page(#{@page.id})"

    parser.parse

    parsed_page = parser.parsed_page

    index_title(parsed_page)
    index_links
    index_headers(parsed_page)

    Rails.logger.debug "Finished IndexPage for Page(#{@page.id})"
  end

  private

  def index_title(parsed_page)
    Rails.logger.debug "Starting IndexPage.index_title for Page(#{@page.id})"

    title = parsed_page[:title]
    return unless title.present?

    index_page_text(title, "title", 3, 10)
  end

  def index_links
    Rails.logger.debug "Starting IndexPage.index_links for Page(#{@page.id})"
    link_texts = @page.links_to.where.not(text: [nil, ""]).pluck(:text)
    return if link_texts.blank?

    link_texts.each do |link_text|
      index_page_text(link_text, "link", 2, 3)
    end
  end

  def index_headers(parsed_page)
    Rails.logger.debug "Starting IndexPage.index_headers for Page(#{@page.id})"

    parsed_page[:headers].each do |header|
      index_page_text(header, "header", 1, 2)
    end
  end

  def index_paragraphs(parsed_page)
    parsed_page[:paragraphs].each do |paragraph|
      index_page_text(page, paragraph, "paragraph", 1, 2)
    end
  end

  def index_page_text(input_string, kind, max_distance, max_length)
    words_array = sanitize_query_text(input_string)
    matcher = SiteScraper::Matcher.new(page.id, words_array, kind, max_distance, max_length)
    matcher.create_matches
  end

  def sanitize_query_text(input_string)
    input_string.dup.tap do |str|
      str.strip! # Remove leading and trailing whitespace
      str.downcase! # Only use lowercase characters
      str.gsub!(/[^\w\s]/, "") # Keep only alphanumeric characters, in English (for now?)
      str.gsub!(/\ba\b|\bor\b|\ban\b|\bthe\b|\band\b|\bof\b/, "") # Remove silly words. TODO: do this a better way
      str.gsub!(/\s+/, " ") # Replace inner substrings of whitespace with single space
      str.strip! # Remove leading and trailing whitespace again
    end.split(" ") # split into an array of words
  end
end
