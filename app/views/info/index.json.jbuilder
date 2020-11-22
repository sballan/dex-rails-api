json.pages do
  json.count @page_count
end

json.links do
  json.count @link_count
end

json.queries do
  json.count @query_count
end

json.results do
  json.count @result_count
end