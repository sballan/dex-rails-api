module Command
  module Base
    class Abstract
      # @return [Command::Base::Result]
      attr_reader :result

      def initialize
        @result = Command::Base::Result.new(self.class.name)
      end

      def run_proc
        throw "must override #{__method__}"
      end

      def run
        run!
      rescue StandardError => e
        Rails.logger.warn "Uncaught Error in #{self.class.name}:\n #{e}"
        result.fail!(e)
      rescue Errors::CommandFailure => e
        result.fail!(e)
      end

      def run!
        run_proc
        assert_success
      end

      # @param [Command::Base::Abstract] command
      def run_nested(command)
        command.run
        result.results << command.result
      end

      # @param [Command::Base::Abstract] command
      def run_nested!(command)
        command.run!
        result.results << command.result
        assert_success
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

      private

      def assert_success
        unless success?
          Rails.logger.error "Command (#{self.class.name}) did not succeed"
          raise Errors::CommandFailure
        end
      end
    end
  end
end