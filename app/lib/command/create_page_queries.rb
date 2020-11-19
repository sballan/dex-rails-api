module Command
  class CreatePageQueries < Command::Base::Abstract
    # @param [Page] page
    def initialize(page)
      @page = page

      @result = Command::Base::Result.new(self.class.basename)
    end

    def run
      create_or_find_query_command = Command::CreateOrFindQuery.new(@page.title)
      run_nested(create_or_find_query_command)
      query = create_or_find_query_command.payload

      create_or_find_result_command = Command::CreateOrFindResult.new(query, @page, 'title')
      run_nested(create_or_find_result_command)

      page.links_to.in_batches.each_record do |link|
        create_link_queries(link)
      end
    end

    private

    def create_link_queries(link)
      create_or_find_query_command = Command::CreateOrFindQuery.new(link.text)
      run_nested(create_or_find_query_command)
      query = create_or_find_query_command.payload

      create_or_find_result_command = Command::CreateOrFindResult.new(query, @page, 'link')
      run_nested(create_or_find_result_command)
    end
  end
end