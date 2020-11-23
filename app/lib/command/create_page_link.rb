module Command
  class CreatePageLink < Command::Base::Abstract
    def initialize(from_page, url, text = nil)
      super()
      @from_page = from_page
      @url = url
      @text = text
    end

    def run_proc
      create_or_find_page_command = Command::CreateOrFindPage.new(@url)
      run_nested!(create_or_find_page_command)
      to_page = create_or_find_page_command.payload

      create_or_find_link_command = Command::CreateOrFindLink.new(@from_page.id, to_page.id, @text)
      run_nested!(create_or_find_link_command)
      link = create_or_find_link_command.payload

      result.succeed!(link)
    end
  end
end