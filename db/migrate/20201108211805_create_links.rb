class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.references :from, null: false, foreign_key: {to_table: :pages}
      t.references :to, null: false, foreign_key: {to_table: :pages}
      t.string :text

      t.timestamps
    end
  end
end
