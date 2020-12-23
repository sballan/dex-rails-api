require 'base64'

module Command
  class UploadQueryResults < Command::Base::Abstract
    def initialize(query)
      super()
      @query = query
    end

    def run_proc
      client = S3Client.new(ENV['DO_DEFAULT_BUCKET'], 'query_results')
      key = Base64.urlsafe_encode64(@query.text)

      body = generate_results.to_json
      client.write_private(key: key, body: body)

      @query.cached_at = DateTime.now.utc
      @query.save!

      result.succeed!(body)
    end

    def generate_results
      @query.results.includes(:page).map do |result|
        {
          kind: result.kind,
          page: {
            url: result.page.url,
            title: result.page.title
          }
        }
      end
    end
  end
end