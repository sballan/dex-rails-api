class CreateInvertedIndex < ActiveRecord::Migration[7.1]
  def change
    create_table :terms do |t|
      t.string :term, null: false
    end

    create_table :documents do |t|
      t.timestamps
    end

    create_table :postings do |t|
      t.references :term, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.integer :position, null: false
      t.timestamps
    end

    add_index :terms, :term, unique: true
    add_index :postings, [:term_id, :document_id, :position], unique: true
  end
end
