wiki_page = Page.create_or_find_by! url: "wikipedia.org"
rails_page = Page.create_or_find_by! url: "https://rubyonrails.org"

wiki_page.links_to.create! to: rails_page;

q = Query.create text: "My Text";

r = Result.create kind: "title", page: wiki_page, query: q
