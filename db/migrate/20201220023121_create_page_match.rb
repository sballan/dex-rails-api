class CreatePageMatch < ActiveRecord::Migration[6.0]
  def change
    create_table :page_matches do |t|
      t.references :query, null: false, foreign_key: true

      t.string :match
      t.string :kind
      t.boolean :full
      t.integer :distance
      t.integer :length
    end
  end
end
