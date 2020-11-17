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

      def success?
        result.status == :success
      end

      def failure?
        result.status == :failure
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