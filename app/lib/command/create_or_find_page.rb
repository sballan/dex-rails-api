module Command
  class CreateOrFindPage < Command::Base::Abstract
    def initialize(url, title = nil)
      super()
      @url = url
      @title = title
    end

    def run_proc
      page = Page.create_or_find_by!(url: @url)

      if page.title != @title
        page.title = @title
        page.save!
      end

      result.succeed!(page)
    end
  end
end