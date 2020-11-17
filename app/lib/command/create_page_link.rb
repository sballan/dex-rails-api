module Command
  class CreatePageLink < Command::Base::Abstract
    def initialize(page, url, text = nil)
      @page = page
      @url = url
      @text = text
      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested(create_or_find_page_command)

      if(create_or_find_page_command.failure?)
        result.fail!(create_or_find_page_command.error)
        return
      end

      to_page = create_or_find_page_command.payload
      # NOTE: Can probably do a better job here using create instead of create! with error catcher
      link = Link.create!(from: @page, to: to_page, text: @text)
      result.succeed!(link)
    rescue StandardError => e
      result.fail!(e)
    end
  end
end