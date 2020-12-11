module Command
  class CreateOrFindQuery < Command::Base::Abstract
    # @param [String] text
    def initialize(text)
      super()
      @text = text.downcase[0..999] # business rule, query cannot be longer than 1000 chars
    end

    def run_proc
      query = Query.create_or_find_by!(text: @text)
      result.succeed!(query)
    end
  end
end