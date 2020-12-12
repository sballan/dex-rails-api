module Command
  class CreateOrFindResult < Command::Base::Abstract
    def initialize(query_id, page_id, kind)
      super()
      @query_id = query_id
      @page_id = page_id
      @kind = kind
    end

    def run_proc
      query = create_or_find_result
      result.succeed!(query)
    end

    def create_or_find_result
      Result.find_or_create_by!(query: @query_id, page: @page_id, kind: @kind)
    rescue ActiveRecord::RecordInvalid => e
      Result.find_by!(query: @query_id, page: @page_id, kind: @kind)
    end
  end
end