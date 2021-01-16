require "rails_helper"

describe ActiveLock::Lock do
  before do
    @mock_redis = MockRedis.new
    allow(ActiveLock::Config).to receive(:redis_connection).and_return(@mock_redis)
  end

  let(:test_lock_name) { 'test_lock_name' }
  let(:redis_test_lock_name) { ActiveLock::Config::PREFIX + test_lock_name }

  after(:each) do
    @mock_redis.del(redis_test_lock_name)
  end

  describe "lock" do
    context "lock is available" do
      it "gets the lock" do
        key = ActiveLock::Lock.lock(test_lock_name)
        found_key = @mock_redis.get(redis_test_lock_name)
        expect(found_key).to eql(key)
      end
    end
  end

  describe "unlock" do
    it "can unlock existing lock" do
      key = 'test_lock_key'
      @mock_redis.set(redis_test_lock_name, key)
      found_key = @mock_redis.get(redis_test_lock_name)
      expect(found_key).to eql(key)

      ActiveLock::Lock.unlock(test_lock_name, key)

      found_key = @mock_redis.get(redis_test_lock_name)
      expect(found_key).to be_nil
    end
  end

  context "private methods" do
    describe "write_lock" do
      it "writes the correct key" do
        key = 'test_lock_key'
        ActiveLock::Lock.send(:write_lock, test_lock_name, key)
        found_key = @mock_redis.get(redis_test_lock_name)
        expect(found_key).to eql(key)
      end
    end

    describe "fetch_lock_key" do
      it "fetches the correct key" do
        key = 'test_lock_key'
        @mock_redis.set(redis_test_lock_name, key)
        found_key = ActiveLock::Lock.send(:fetch_lock_key, test_lock_name)
        expect(key).to eql(found_key)
      end
    end

    describe "delete_lock" do
      it "deletes correct lock" do
        other_test_lock_name = 'other_text_lock_name'
        other_redis_test_lock_name = ActiveLock::Config::PREFIX + other_test_lock_name
        other_key = 'other_test_lock_key'
        @mock_redis.set(other_redis_test_lock_name, other_key)

        key = 'test_lock_key'
        @mock_redis.set(redis_test_lock_name, key)
        ActiveLock::Lock.send(:delete_lock, test_lock_name)

        found_key = @mock_redis.get(redis_test_lock_name)
        other_found_key = @mock_redis.get(other_redis_test_lock_name)

        expect(found_key).to be_nil
        expect(other_found_key).to eql(other_key)
      end
    end
  end
end
