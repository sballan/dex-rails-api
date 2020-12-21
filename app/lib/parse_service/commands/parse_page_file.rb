module ParseService::Commands
  class ParsePageFile < Command::Base::Abstract
    def initialize(url, page_file)
      super()
      @url = url
      @page_file = page_file
    end

    def run_proc
      Rails.logger.debug "[Parse::ParsePageFile] Starting Parse for #{@url}"
      parsed_page = parse_page
      Rails.logger.debug "[Parse::ParsePageFile] Finished Parse for #{@url}"
      result.succeed!(parsed_page)
    end

    private

    def parse_page
      doc = Nokogiri::HTML(@page_file)

      parsed_page = {
        title: doc.title.blank? ? nil : doc.title,
        body: Html2Text.convert(doc.to_html.force_encoding('UTF-8')),
        headers: [],
        links: []
      }

      doc.css('a').each do |link_node|
        next if link_node['href'].blank?

        parsed_page[:links] << {
            url: URI.parse(@url).merge(URI.parse(link_node['href'])).to_s,
            text: link_node.content.blank? ? nil : link_node.content.strip.gsub(/\s+/, " ")
        }
      end

      doc.css('h1').each do |header_node|
        next if header_node.text.blank?

        parsed_page[:headers] << header_node.text
      end

      # Removes a nil title
      parsed_page.compact
    end
  end
end
