class CacheBatchJob < ApplicationJob
  queue_as :cache

  def perform(size=100)
    CacheService::Client.cache_batch(size)
  end
end
