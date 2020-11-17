module Command
  class CreatePageLink < Command::Base::Abstract
    def initialize(page, url, text = nil)
      @page = page
      @url = url
      @text = text
      @result = Command::Base::Result.new
    end

    def run
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested(create_or_find_page_command)

      if(create_or_find_page_command.failure?)
        result.fail!(create_or_find_page_command.error)
        return
      end

      # NOTE: Can probably do a better job here using create instead of create! with error catcher
      link = Link.create!(from: @page, to: create_or_find_page_command.payload, text: @text)
      result.succeed!(link)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end