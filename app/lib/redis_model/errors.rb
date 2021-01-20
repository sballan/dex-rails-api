module RedisModel::Errors
  class Base < StandardError; end
  class IdNotUniqueError < Base; end
  class RecordMissingError < Base; end
  class ModelConfigurationError < Base; end
end
