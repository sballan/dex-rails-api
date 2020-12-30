require "rails_helper"

describe JobBatch::Lock do
  before do
    @mock_redis = MockRedis.new
    allow(JobBatch).to receive(:redis).and_return(@mock_redis)
  end

  context "private method" do
    describe "write_lock" do
      let(:test_lock_name) { 'test_lock_name' }
      let(:redis_test_lock_name) { JobBatch::LOCK_PREFIX + test_lock_name }

      after(:each) do
        @mock_redis.del(test_lock_name)
      end

      it "writes the correct key" do
        key = 'test_lock_key'
        JobBatch::Lock.send(:write_lock, test_lock_name, key)
        found_key = @mock_redis.get(redis_test_lock_name)
        expect(found_key).to eql(key)
      end
    end
  end
end
