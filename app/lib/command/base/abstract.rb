module Command
  module Base
    class Abstract
      # @return [Command::Base::Result]
      attr_reader :result

      def initialize
        run
        throw 'Abstract Class cannot be instantiated'
      end

      def run
        throw "must override #{__method__}"
      end

      # @param [Command::Base::Abstract] command
      def run_nested(command)
        command.run
        result.results << command.result
      end

      def success?
        result.success?
      end

      def failure?
        result.failure?
      end

      def payload
        result.payload
      end

      def error
        result.error
      end

    end
  end
end