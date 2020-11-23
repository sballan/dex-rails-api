module Command
  class CreateOrFindResult < Command::Base::Abstract
    def initialize(query, page, kind)
      super()
      @query = query
      @page = page
      @kind = kind
    end

    def run_proc
      query = create_or_find_result
      result.succeed!(query)
    end

    def create_or_find_result
      Result.find_or_create_by!(query: @query, page: @page, kind: @kind)
    rescue ActiveRecord::RecordInvalid => e
      Result.find_by!(query: @query, page: @page, kind: @kind)
    end
  end
end