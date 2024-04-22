module FetchService::Commands
  # This class should persist:
  # 1. links that appear on a page
  # 2. title of the page
  # 3. syntactically marked important text (headers, bold, whatever)
  # 4. semantically important text (using heuristics)
  #
  # So far, it can only do the first two, and these it doesn't do very well.  I think
  # eventually, I'll want a single table for holding all 'words', with other tables referencing
  # them for making things like 'titles', etc.  Querying may be extremely slow - but this is all
  # just being used to populate a cache anyhow! Yay Rails.
  class PersistParsedPage < Command::Abstract
    def initialize(page, parsed_page)
      super()
      @page = page
      @parsed_page = parsed_page
    end

    def run_proc
      if @parsed_page[:title].present? && @page.title != @parsed_page[:title]
        @page.title = @parsed_page[:title]
        @page.save!
      end
      insert_links
      result.succeed!
    end

    private

    def insert_links
      return if @parsed_page[:links].blank?
      command = InsertLinks.new(@page, @parsed_page)
      command.run!
    end
  end
end
