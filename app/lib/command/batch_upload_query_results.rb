module Command
  class BatchUploadQueryResults < Command::Base::Abstract
    def initialize(limit=nil)
      super()
      @limit = limit
    end

    def run_proc
      rel = @limit ? Query.next_to_cache(@limit) : Query.next_to_cache
      query_ids = rel.pluck(:id)

      Query.where(id: query_ids).in_batches.each_record do |query|
        command = Command::UploadQueryResults.new(query)
        run_nested!(command)
      end

      result.succeed!
    end
  end
end