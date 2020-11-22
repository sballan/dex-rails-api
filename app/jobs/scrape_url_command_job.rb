class ScrapeUrlCommandJob < ApplicationJob
  queue_as :default

  def perform(url)
    command = Command::ScrapeUrl.new(url)
    command.run
    unless command.success?
      raise "Command failed!"
    end
  end
end
