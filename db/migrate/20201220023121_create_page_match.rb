class CreatePageMatch < ActiveRecord::Migration[6.0]
  def change
    create_table :page_matches do |t|
      t.references :query, null: false, foreign_key: true
      t.references :page, null: false, foreign_key: true

      t.string :kind
      t.boolean :full
      t.integer :distance
      t.integer :length
    end

    add_index :page_matches, %i[query_id page_id kind full distance length], unique: true, name: :index_page_matches_on_query_page_kind_full_distance_length
  end
end
