module Command
  module Base
    class Result
      attr_reader :started_at, :finished_at, :payload, :status, :error, :results

      def initialize
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
        @results = results
        finish!
      end

      def succeed!(payload = nil, results = [])
        @status = :success
        @payload = payload
        @results = results
        finish!
      end

      private

      def finish!
        @finished_at = DateTime.now.utc
      end
    end
  end
end