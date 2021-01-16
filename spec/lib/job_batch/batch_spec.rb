require "rails_helper"

describe JobBatch::Batch do
  before do
    @mock_redis = MockRedis.new
    allow(ActiveLock::Config).to receive(:redis_connection).and_return(@mock_redis)
    allow(RedisModelOld).to receive(:redis).and_return(@mock_redis)
    allow(JobBatch).to receive(:redis).and_return(@mock_redis)
  end

  describe "Basics" do
    it "can be instantiated with a batch_id" do
      batch_id = SecureRandom.uuid
      batch = JobBatch::Batch.new(batch_id)
      expect(batch).to be
    end

    it "can be created" do
      batch = JobBatch::Batch.create
      found = @mock_redis.exists?(batch.key)
      expect(found).to be_truthy
    end

    it "can have data" do
      batch = JobBatch::Batch.create

      batch.with_data do |data|
        expect(data).to be_present
      end
    end

    it "can have a job" do
      batch_id = SecureRandom.uuid
      job_id = SecureRandom.uuid

      batch = JobBatch::Batch.create(batch_id)
      job = JobBatch::Job.create(job_id, batch_id: batch.id)

      has_job = batch.jobs.any? {|j| j.id == job_id }
      expect(has_job).to be_truthy
    end
  end

  describe "key" do
    it "returns the key for the Batch" do
      job = JobBatch::Batch.new 'test_id'
      expect(job.key).to eql('JobBatch/Batches/test_id/record')
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

  describe "jobs" do
    context "no jobs exist" do
      let(:batch) { JobBatch::Batch.create }

      it "returns an Array" do
        expect(batch.jobs).to be_a(Array)
      end

      it "can be used to return a count of 0" do
        expect(batch.jobs.count).to eql(0)
      end
    end

    context "jobs exist" do
      let(:batch) { JobBatch::Batch.create }
      let(:job1) { JobBatch::Job.create(SecureRandom.uuid, batch_id: batch.id) }

      it "can get a job in it's batch" do
        job1 # So dumb - but for some reason, if we don't invoke job1 first - rspec doesn't run the let block? or something?  it doesn't exist until we do this.
        expect(batch.jobs).to include(job1)
      end
    end
  end
end
