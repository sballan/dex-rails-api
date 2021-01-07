class GcCompactJob < ApplicationJob
  queue_as :default

  def perform
    GC.start full_mark: true, immediate_sweep: true
    GC.compact
  end
end
