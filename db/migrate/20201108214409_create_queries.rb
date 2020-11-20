class CreateQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :queries do |t|
      t.string :text, null: false

      t.timestamps
    end
    add_index :queries, :text, unique: true
  end
end
