require "rails_helper"

describe ActiveLock::Lockable do
  before do
    @mock_redis = MockRedis.new
    allow(ActiveLock::Config).to receive(:redis_connection).and_return(@mock_redis)
    allow(ActiveLock::Config).to receive(:lock_default_opts)
      .and_return({
        ttl: 1.hour,
        retry_time: 1.second,
        retry_wait: 0.01.seconds
      })
  end

  let(:test_lock_name) { "test_lock_name" }
  let(:redis_test_lock_name) { ActiveLock::Config::PREFIX + test_lock_name }

  after(:each) do
    @mock_redis.flushdb
  end

  class MockLockable
    include ActiveLock::Lockable
    set_lock_id_name :id

    def id
      @id ||= SecureRandom.uuid
    end
  end

  context "included" do
    let(:lockable) { MockLockable.new }
    describe "lock" do
      it "returns the lock key" do
        key = lockable.lock
        expected_key = @mock_redis.get(ActiveLock::Config::PREFIX + lockable.id)

        expect(key).to eql(expected_key)
      end

      it "returns false if already locked" do
        successful_key = lockable.lock
        failed_key = lockable.lock

        expect(successful_key).to be_a String
        expect(failed_key).to eql(false)
      end
    end
  end
end
