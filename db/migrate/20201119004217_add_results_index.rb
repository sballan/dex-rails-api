class AddResultsIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :results, %i[query_id page_id kind], unique: true
  end
end
