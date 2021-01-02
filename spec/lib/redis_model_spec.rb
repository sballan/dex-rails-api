require "rails_helper"

describe RedisModel do
  before do
    @mock_redis = MockRedis.new
    allow(RedisModel).to receive(:redis).and_return(@mock_redis)
    allow(ActiveLock::Config).to receive(:redis).and_return(@mock_redis)
  end

  context "Basics" do
    let(:model) { RedisModel.create SecureRandom.uuid }

    it "can be created with an id" do
      expect(model).to be
    end

    it "has a Redis key" do
      key = model.key
      expect(@mock_redis.exists?(key)).to be_truthy
    end


    it "can be found" do
      m = RedisModel.find(model.id)
      expect(m.id).to eql(model.id)
    end


    it "can have data" do
      model = RedisModel.create

      model.with_data do |data|
        expect(data).to be_present
        expect(data[:id]).to be_present
      end
    end
  end

  describe "with_lock" do
    let(:id) { SecureRandom.uuid }
    let(:model) { RedisModel.new(id) }

    it "is locked inside the block" do
      model.with_lock do
        expect(@mock_redis.get(ActiveLock::Config::PREFIX + id)).to be_truthy
      end
    end

    it "is unlocked before and after the block" do
      expect(@mock_redis.get(ActiveLock::Config::PREFIX + id)).to be_falsey
      model.with_lock {
        expect(@mock_redis.get(ActiveLock::Config::PREFIX + id)).to be_truthy
      }
      expect(@mock_redis.get(ActiveLock::Config::PREFIX + id)).to be_falsey
    end
  end

end
