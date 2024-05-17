class CacheQueryJob < ApplicationJob
  # include JobBatch::Mixin

  queue_as :cache

  def perform(query_id)
    query = Query.find(query_id)

    CacheService::Client.cache_query(query)
  end
end
