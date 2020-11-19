class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.string :url
      t.string :title

      t.datetime "download_success"
      t.datetime "download_failure"
      t.datetime "download_invalid"

      t.timestamps
    end
    add_index :pages, :url, unique: true
  end
end
