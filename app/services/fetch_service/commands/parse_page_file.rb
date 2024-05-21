module FetchService::Commands
  class ParsePageFile < Command::Abstract
    def initialize(url, page_file)
      super()
      @url = url
      @page_file = page_file
    end

    def run_proc
      Rails.logger.debug "[Parse::ParsePageFile] Starting Parse for #{@url}"
      parsed_page = parse_page
      Rails.logger.debug "Here is the parsed page! #{parsed_page}"
      Rails.logger.debug "[Parse::ParsePageFile] Finished Parse for #{@url}"
      result.succeed!(parsed_page)
    end

    private

    def parse_page
      doc = Nokogiri::HTML(@page_file)

      parsed_page = {
        title: doc.title.blank? ? nil : doc.title,
        body: Html2Text.convert(doc.to_html.force_encoding("UTF-8")),
        headers: [],
        links: [],
        paragraphs: []

      }

      url_without_fragment = URI.parse(@url).tap { |uri| uri.fragment = nil }.to_s

      doc.css("a").each do |link_node|
        next if link_node["href"].blank?

        begin
          uri = URI.parse(@url).merge(URI.parse(link_node["href"]))
          uri.fragment = nil

          # Skip if the link is to the same page
          next if uri.to_s == url_without_fragment

          parsed_page[:links] << {
            url: uri.to_s,
            text: link_node.content.blank? ? nil : link_node.content.strip.gsub(/\s+/, " ")
          }
        rescue URI::InvalidURIError
          # TODO: revisit how we're parsing this URL
          next
        end
      end

      ["h1", "h2", "h3", "h4", "h5", "h6"].each do |header_tag|
        doc.css(header_tag).each do |header_node|
          next if header_node.text.blank?

          parsed_page[:headers] << header_node.text
        end
      end

      doc.css("p").each do |header_node|
        next if header_node.text.blank?

        parsed_page[:paragraphs] << header_node.text
      end

      # Removes a nil title
      parsed_page.compact
    end
  end
end
