module Command
  class CreateOrFindPage < Command::Base::Abstract
    def initialize(url, title = nil)
      @url = url
      @title = title

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      page = Page.create_or_find_by!(url: @url)

      if page.title != @title
        page.title = @title
        page.save!
      end

      result.succeed!(page)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end