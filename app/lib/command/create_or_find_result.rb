module Command
  class CreateOrFindResult < Command::Base::Abstract
    def initialize(query, page, kind)
      @query = query
      @page = page
      @kind = kind

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      query = create_or_find_result
      result.succeed!(query)
    rescue StandardError => e
      result.fail!(e)
    end

    def create_or_find_result
      Result.find_or_create_by!(query: @query, page: @page, kind: @kind)
    rescue ActiveRecord::RecordInvalid => e
      Result.find_by!(query: @query, page: @page, kind: @kind)
    end
  end
end