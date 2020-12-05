module Command
  class BatchRefreshPages < Command::Base::Abstract
    def initialize(start=nil, finish=nil, limit=100)
      super()
      @start = start
      @finish = finish
      @limit = limit
    end

    def run_proc
      Page.all.limit(@limit).in_batches(start: @start, finish: @finish).each_record.pluck(:url) do |url|
        command = Command::RefreshPage.new url
        run_nested!(command)
      end

      result.succeed!
    end
  end
end