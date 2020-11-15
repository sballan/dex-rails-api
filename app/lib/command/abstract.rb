module Command
  class Abstract
    attr_reader :result, :error

    def initialize
      run
      throw 'Abstract Class cannot be instantiated'
    end

    def run
      throw "must override #{__method__}"
    end

    def success?
      result[:status] == :success
    end

    def failure?
      result[:status] == :failure
    end

  end
end