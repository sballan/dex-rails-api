describe JobBatch::Batch do
  before do
    @mock_redis = MockRedis.new
    allow(ActiveLock::Config).to receive(:redis).and_return(@mock_redis)
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

    it "can add a job" do
      batch_id = SecureRandom.uuid
      job_id = SecureRandom.uuid

      batch = JobBatch::Batch.new(batch_id)
      job = JobBatch::Job.new(job_id)

      batch.add_job(job)
      has_job = batch.jobs.any? {|j| j.id == job_id }
      expect(has_job).to be_truthy
    end
  end

  describe "with_lock" do
    let(:batch_id) { SecureRandom.uuid }
    let(:batch) { JobBatch::Batch.new(batch_id) }

    it "is locked inside the block" do
      batch.with_lock do
        expect(@mock_redis.get(ActiveLock::Config::PREFIX + batch_id)).to be_truthy
      end
    end

    it "is unlocked before and after the block" do
      expect(@mock_redis.get(ActiveLock::Config::PREFIX + batch_id)).to be_falsey
      batch.with_lock {}
      expect(@mock_redis.get(ActiveLock::Config::PREFIX + batch_id)).to be_falsey
    end
  end
end
