module Command
  module Base
    class Result
      attr_reader :started_at, :finished_at, :payload, :status, :error, :results

      def initialize(command_name)
        @command_name = command_name
        @started_at = DateTime.now.utc
        @finished_at = nil
        @payload = nil
        @status = :failure
        @error = nil
        @results = []
      end

      def start!
        @started_at = DateTime.now.utc
      end

      def fail!(error = nil, results = [])
        @status = :failure
        @error = error
        @results.concat(results)
        finish!
      end

      def succeed!(payload = nil, results = [])
        @status = :success
        @payload = payload
        @results.concat(results)
        finish!
      end

      def success?
        status == :success
      end

      def failure?
        status == :failure
      end

      private

      def finish!
        @finished_at = DateTime.now.utc
      end
    end
  end
end