module Command
  class CreateOrFindResult < Command::Base::Abstract
    def initialize(query, page, kind)
      @query = query
      @page = page
      @kind = kind

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      query = Result.create_or_find_by!(query: @query, page: @page, kind: @kind)
      result.succeed!(query)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end