class ScrapeUrlCommandJob < ApplicationJob
  queue_as :default

  def perform(url, force=false)
    command = Command::ScrapeUrl.new(url)
    force ? command.run! : command.run
  end
end
