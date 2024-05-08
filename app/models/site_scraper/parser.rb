class SiteScraper::Parser
  class ParserError < StandardError
  end

  class PermanentFailure < ParserError
  end

  class TemporaryFailure < ParserError
  end

  attr_reader :parsed_page

  private attr_reader :downloader

  def initialize(downloader)
    @downloader = downloader
    @doc = nil
    @parsed_page = {
      title: nil,
      body: nil,
      headers: [],
      links: [],
      paragraphs: []
    }
  end

  def doc
    @doc ||= Nokogiri::HTML(downloader.cache)
  end

  def parse
    @parsed_page[:title] = doc.title.blank? ? nil : doc.title
    @parsed_page[:body] = Html2Text.convert(doc.to_html.force_encoding("UTF-8"))

    # Removes a nil title and body
    @parsed_page.compact

    parse_links
    parse_headers
    parse_paragraphs
  end

  def parse_links
    doc.css("a").each do |link_node|
      next if link_node["href"].blank?

      begin
        # uri = URI.parse(link_node["href"])
        # uri.fragment = nil
        @parsed_page[:links] << {
          url: URI.parse(@url).merge(URI.parse(link_node["href"])).to_s,
          text: link_node.content.blank? ? nil : link_node.content.strip.gsub(/\s+/, " ")
        }
      rescue URI::InvalidURIError
        # TODO: revisit how we're parsing this URL
        next
      end
    end
  end

  def parse_headers
    ["h1", "h2", "h3", "h4", "h5", "h6"].each do |header_tag|
      doc.css(header_tag).each do |header_node|
        next if header_node.text.blank?

        @parsed_page[:headers] << header_node.text
      end
    end
  end

  def parse_paragraphs
    doc.css("p").each do |paragraph_node|
      next if paragraph_node.text.blank?

      @parsed_page[:paragraphs] << paragraph_node.text
    end
  end
end
