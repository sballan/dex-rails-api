module Command
  class CreateOrFindPage < Command::Base::Abstract
    def initialize(url)
      @url = url

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      page = Page.create_or_find_by!(url: @url)
      result.succeed!(page)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end