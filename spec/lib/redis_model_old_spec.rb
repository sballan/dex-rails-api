require "rails_helper"

describe RedisModelOld do
  before do
    @mock_redis = MockRedis.new
    allow(RedisModelOld).to receive(:redis).and_return(@mock_redis)
    allow(ActiveLock::Config).to receive(:redis_connection).and_return(@mock_redis)
  end

  context "Basics" do
    let(:model) { RedisModelOld.create SecureRandom.uuid }

    it "can be created with an id" do
      expect(model).to be
    end

    it "has a Redis key" do
      key = model.key
      expect(@mock_redis.exists?(key)).to be_truthy
    end

    it "can be found" do
      m = RedisModelOld.find(model.id)
      expect(m.id).to eql(model.id)
    end

    it "can have data" do
      model = RedisModelOld.create

      model.with_data do |data|
        expect(data).to be_present
        expect(data[:id]).to be_present
      end
    end
  end

  describe "with_lock" do
    let(:id) { SecureRandom.uuid }
    let(:model) { RedisModelOld.new(id) }

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

  context "Subclasses" do
    class MockAuthor < RedisModelOld; end

    class MockBook < RedisModelOld; end

    class MockAuthor < RedisModelOld
      has_many :books, "MockBook", inverse_of: :author
    end

    class MockBook < RedisModelOld
      belongs_to :author, "MockAuthor", inverse_of: :books
    end

    describe "belongs_to" do
      it "can be created with the id of the class it belongs to" do
        author = MockAuthor.create
        book = MockBook.create nil, author_id: author.id
        expect(book.author == author).to be_truthy
        # expect(book.author).to eql(author)
      end
    end
  end
end
