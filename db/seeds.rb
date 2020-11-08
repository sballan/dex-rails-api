wiki_page = Page.new url: "wikipedia.org"
rails_page = Page.new url: "https://rubyonrails.org"

wiki_page.links_to.new to: rails_page;