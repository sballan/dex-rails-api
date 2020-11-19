module Command
  class CreateOrFindQuery < Command::Base::Abstract
    def initialize(text)
      @text = text

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      query = Query.create_or_find_by!(text: @text)
      result.succeed!(query)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end