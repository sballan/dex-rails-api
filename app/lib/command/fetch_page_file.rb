module Command
  class FetchPageFile < Command::Base::Abstract
    def initialize(page_id)
      super()
      @page_id = page_id
    end

    def run_proc
      client = S3Client.new(ENV['DEV_BUCKET'], 'page_files')
      body = client.read(key: @page_id).body.read
      result.succeed!(body)
    end
  end
end