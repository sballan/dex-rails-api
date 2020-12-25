module Command
  class Abstract
    # @return [Command::Result]
    attr_reader :result

    def initialize
      @result = Command::Result.new(self.class.name)
    end

    def run_proc
      throw "must override #{__method__}"
    end

    def run
      run!
    rescue Errors::CommandInvalid => e
      Rails.logger.debug "Caught an invalid command. This is ok, but if possible try to avoid running this command in the first place.  \nError: #{self.class.name}:\n #{e}"
    rescue Errors::CommandFailed => e
      Rails.logger.error "Caught a failed command. \nError: #{self.class.name}:\n #{e}"
      result.fail!(e)
    rescue StandardError => e
      Rails.logger.warn "Uncaught Error in #{self.class.name}:\n #{e}"
      result.fail!(e)
    rescue Errors::Generic => e
      result.fail!(e)
    end

    def run!
      result.start!
      run_proc
      assert_success
    rescue StandardError => e
      # This plugs us into Bugsnag.  Errors capture here will not be double reported if they bubble all the way up.
      Bugsnag.notify(e)
      e.instance_eval { def skip_bugsnag; true; end }
      raise e
    end

    # @param [Command::Abstract] command
    def run_nested(command)
      command.run
      result.results << command.result
    end

    # @param [Command::Abstract] command
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
        backtrace = error.respond_to?(:backtrace) && error.backtrace.present? ? error.backtrace.join("\n") : nil
        command_failure_message = "Command (#{self.class.name}) did not succeed (#{error.class}): \n#{backtrace}"
        raise Command::Errors::CommandFailed.new(command_failure_message, error)
      end
    end

    def with_gc(&block)
      GC.start(full_mark: true, immediate_sweep: true)
      block.call
      GC.start(full_mark: true, immediate_sweep: true)
    end
  end
end
