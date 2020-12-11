class ScrapeUrlCommandJob < ApplicationJob
  queue_as :scrape

  def perform(url, force=false)
    GC.start(full_mark: true, immediate_sweep: true)

    command = Command::ScrapeUrl.new(url)
    force ? command.run_with_gc! : command.run_with_gc

    GC.start(full_mark: true, immediate_sweep: true)
  end
end
