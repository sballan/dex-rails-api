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
        command.run
        result.results << command.result
        command.assert_success
      end

      def run_with_gc
        with_gc { run }
      end

      def run_with_gc!
        with_gc { run! }
      end

      def run_nested_with_gc(*args)
        with_gc { run_nested(*args) }
      end

      def run_nested_with_gc!(*args)
        with_gc { run_nested!(*args) }
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

      protected

      def assert_success
        unless success?
          raise Command::Base::Errors::CommandFailure, "Command (#{self.class.name}) did not succeed"
        end
      end

      def with_gc(&block)
        GC.start(full_mark: true, immediate_sweep: true)
        block.call
        GC.start(full_mark: true, immediate_sweep: true)
      end
    end
  end
end