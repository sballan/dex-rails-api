require "rails_helper"

describe Command::Abstract do
  context "Basics" do
    it "can be subclassed with a run_proc implementation" do
      class BasicsTestCommand < Command::Abstract
        def run_proc
          true
        end
      end

      test_command = BasicsTestCommand.new
      expect(test_command).to be
    end
  end

  context "Execution" do
    class ExecutionTestCommand < Command::Abstract
      def initialize(foo)
        super()
        @foo = foo
      end

      def run_proc
        if @foo == "should_fail"
          result.fail!
        elsif @foo == "should_error"
          raise "Error!"
        else
          @foo = "bar: #{@foo}"
          result.succeed!(@foo)
        end
      end
    end

    it "can succeed" do
      command = ExecutionTestCommand.new "should_succeed"
      command.run
      expect(command).to be_success
    end

    it "can fail" do
      command = ExecutionTestCommand.new "should_fail"
      command.run
      expect(command).to be_failure
    end

    it "can error" do
      command = ExecutionTestCommand.new "should_error"
      command.run
      expect(command).to be_failure
    end
  end
end
