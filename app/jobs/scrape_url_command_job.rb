class ScrapeUrlCommandJob < ApplicationJob
  queue_as :default

  def perform(url, force=false)
    GC.start(full_mark: true, immediate_sweep: true)

    command = Command::ScrapeUrl.new(url)
    force ? command.run! : command.run

    GC.start(full_mark: true, immediate_sweep: true)
  end
end
