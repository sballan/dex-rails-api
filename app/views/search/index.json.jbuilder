json.search_text @text

json.pages @pages do |page|
  json.title page.title
  json.url page.url
end