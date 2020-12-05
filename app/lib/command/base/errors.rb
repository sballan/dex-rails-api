module Command
  module Base
    module Errors
      class Generic < StandardError
      end

      class CommandInvalid < Generic
        attr_reader :base_error
        def initialize(message, base_error=nil)
          super(message)
          @base_error = base_error
        end
      end

      class CommandFailed < Generic
        attr_reader :base_error
        def initialize(message, base_error=nil)
          super(message)
          @base_error = base_error
        end
      end
    end
  end
end