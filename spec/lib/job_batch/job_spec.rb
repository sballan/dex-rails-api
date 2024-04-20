require "rails_helper"

describe JobBatch::Job do
  before do
    @mock_redis = MockRedis.new
    allow(JobBatch).to receive(:redis).and_return(@mock_redis)
    allow(RedisModelOld).to receive(:redis).and_return(@mock_redis)
  end

  context "Basics" do
    let(:batch) { JobBatch::Batch.create SecureRandom.uuid }
    let(:job) { JobBatch::Job.create SecureRandom.uuid, batch_id: batch.id }

    it "can be created with a job_id" do
      expect(job).to be
    end

    it "has a Redis key" do
      key = job.key
      expect(@mock_redis.exists?(key)).to be_truthy
    end

    it "has a Batch" do
      expect(job.batch).to be
    end

    it "can be found" do
      j = JobBatch::Job.find(job.id)
      expect(j.id).to eql(job.id)
    end
  end
end
