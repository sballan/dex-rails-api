class GCCompactJob < ApplicationJob
  queue_as :default

  def perform
    GC.compact
  end
end
