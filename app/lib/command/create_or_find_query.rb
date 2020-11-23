module Command
  class CreateOrFindQuery < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text
    end

    def run_proc
      query = Query.create_or_find_by!(text: @text)
      result.succeed!(query)
    end
  end
end