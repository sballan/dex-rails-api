module Command
  module Base
    module Errors
      class Generic < StandardError
      end

      class CommandFailure < Generic
      end
    end
  end
end