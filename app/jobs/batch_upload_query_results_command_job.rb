class BatchUploadQueryResultsCommandJob < ApplicationJob
  queue_as :cache

  def perform(count=100)
    GC.start(full_mark: true, immediate_sweep: true)

    command = Command::BatchUploadQueryResults.new(count)
    command.run

    GC.start(full_mark: true, immediate_sweep: true)
  end
end
