module Command
  class RefreshPages < Command::Base::Abstract
    def initialize(urls)
      super()
      @urls = urls
    end

    def run_proc
      urls_by_host = @urls.group_by {|url| URI.parse(url).host }
      # while any host still has unprocessed urls
      while(urls_by_host.any? {|host, urls| urls.any?}) do
        # pop a url for each host, refresh them all (since we don't worry about rate limits), then sleep
        urls_by_host.each do |host, urls|
          next unless urls.any?
          url = urls.pop
          command = Command::RefreshPage.new url
          run_nested!(command)
        end
        sleep 2
      end

      result.succeed!
    end
  end
end