module FetchService::Commands
  class ProcessNokogiriDoc < Command::Abstract
    def initialize(nokogiri_doc)
      super()
      @nokogiri_doc = nokogiri_doc
    end

    def run_proc
      @nokogiri_doc.xpath('//script').remove
      @nokogiri_doc.xpath('//style').remove
      output = @nokogiri_doc.to_html.force_encoding('UTF-8')
      result.succeed!(output)
    end
  end
end