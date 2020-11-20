module Command
  class CreateOrFindLink < Command::Base:: Abstract
    def initialize(from_page_id, to_page_id, text)
      @from_page_id = from_page_id
      @to_page_id = to_page_id
      @text = text

      @result = Command::Base::Result.new(self.class.name)
    end

    def run
      link = create_or_find_link
      result.succeed!(link)
    rescue StandardError => e
      result.fail!(e)
    end

    def create_or_find_link
      Link.find_or_create_by!(from_id: @from_page_id, to_id: @to_page_id, text: @text)
    rescue ActiveRecord::RecordInvalid => e
      Link.find_by!(from_id: @from_page_id, to_id: @to_page_id, text: @text)
    end
  end
end