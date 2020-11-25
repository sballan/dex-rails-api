module Command
  class CreateOrFindLink < Command::Base::Abstract
    def initialize(from_page_id, to_page_id, text)
      super()
      @from_page_id = from_page_id
      @to_page_id = to_page_id
      @text = text
    end

    def run_proc
      link = create_or_find_link
      result.succeed!(link)
    end

    def create_or_find_link
      Link.find_or_create_by!(from_id: @from_page_id, to_id: @to_page_id, text: @text)
    rescue ActiveRecord::RecordInvalid => e
      Link.find_by!(from_id: @from_page_id, to_id: @to_page_id, text: @text)
    end
  end
end