module Command
  class ExtractPageLinks < Command::Base::Abstract
    def initialize(page, page_file)
      @page = page
      @page_file = page_file
      @nokogiri_page = nil

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      links.each do |link|
        create_page_link_command = Command::CreatePageLink.new(@page, link[:href], link[:text])
        run_nested(create_page_link_command)
      end

      if result.results.any?(&:failure?)
        result.fail!
      else
        result.succeed!
      end
    end

    private

    def links
      nokogiri_page.css('a[href]').map do |a|
        {
          text: a.text,
          href: a['href']
        }
      end
    end

    def nokogiri_page
      return @nokogiri_page unless @nokogiri_page.nil?

      @nokogiri_page = Nokogiri::HTML(@page_file)
      @nokogiri_page
    end
  end
end