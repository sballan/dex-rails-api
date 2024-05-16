class QueueFullCacheQueryJob < ApplicationJob
  queue_as :default

  def perform
    counter = 0
    Query.never_cached.in_batches.each_record do |q|
      counter += 1
      CacheQueryJob.perform_later(q.id)
      if counter % 100_000 == 0
        sleep 10.minutes
      end
    end
  end
end
