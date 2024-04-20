module ActiveLock::Errors
  class Base < StandardError; end

  class FailedToLockError < Base; end

  class FailedToUnlockError < Base; end
end
