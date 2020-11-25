json.search_text @text

json.matches do
  json.merge! @cache_hits
end