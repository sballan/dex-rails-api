module Command
  module Base
    module Errors
      class Generic < StandardError
      end

      class CommandFailure < Generic
        attr_reader :base_error
        def initialize(message, base_error)
          super(message)
          @base_error = base_error
        end
      end
    end
  end
end