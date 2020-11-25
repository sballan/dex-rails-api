module Command
  class CreateOrFindPage < Command::Base::Abstract
    def initialize(url, title = nil)
      super()
      @url = url
      @title = title
    end

    def run_proc
      page = create_or_find_page

      if @title.present? && page.title != @title
        page.title = @title
        page.save!
      end

      result.succeed!(page)
    end

    private

    def create_or_find_page
      Page.find_or_create_by!(url: @url)
    rescue ActiveRecord::RecordInvalid => e
      Page.find_by!(url: @url)
    end
  end
end