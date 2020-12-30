describe JobBatch::Batch do
  before do
    @mock_redis = MockRedis.new
    allow(JobBatch).to receive(:redis).and_return(@mock_redis)
  end

  describe "Basics" do
    it "can be instantiated with a batch_id" do
      batch_id = SecureRandom.uuid
      batch = JobBatch::Batch.new(batch_id)
      expect(batch).to be
    end

    it "can have a job" do
      batch_id = SecureRandom.uuid
      job_id = SecureRandom.uuid
      @mock_redis.mapped_hmset(JobBatch::JOBS_PREFIX + job_id, batch_id: batch_id)

      batch = JobBatch::Batch.new(batch_id)
      has_job = batch.jobs.any? {|j| j.id == job_id }
      expect(has_job).to be_truthy
    end
  end
end
