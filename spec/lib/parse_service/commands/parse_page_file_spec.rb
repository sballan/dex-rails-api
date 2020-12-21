describe ParseService::Commands::ParsePageFile do
  context 'Basics' do
    it 'can be created with a url and a page_file' do
      url = "https://www.test.com"
      page_file = <<-HTML
        <html>
          <head><title>My Test Page</title></head>
          <body><h1>My Test Header</h1></body>
        </html>
      HTML
      command = ParseService::Commands::ParsePageFile.new(url, page_file)
      expect(command).to be
    end
  end

  context 'Execution' do
    let(:url) { "https://www.test.com" }
    let(:page_file) { <<-HTML
      <html>
        <head><title>My Test Page</title></head>
        <body><h1>My Test Header</h1></body>
      </html>
    HTML
    }

    it 'can extract a title' do
      command = ParseService::Commands::ParsePageFile.new(url, page_file)
      command.run!
      expect(command.payload[:title]).to eql('My Test Page')
    end
  end
end
