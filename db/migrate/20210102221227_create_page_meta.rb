class CreatePageMeta < ActiveRecord::Migration[6.0]
  def change
    create_table :page_meta do |t|
      t.references :page, null: false, index: {unique: true}

      t.datetime :fetch_started_at
      t.datetime :fetch_finished_at
      t.datetime :index_started_at
      t.datetime :index_finished_at
      t.datetime :rank_started_at
      t.datetime :rank_finished_at

      t.integer :fetch_status, default: 0
      t.integer :index_status, default: 0
      t.integer :rank_status, default: 0
    end

    add_index :page_meta, :fetch_status
    add_index :page_meta, :index_status
    add_index :page_meta, :rank_status
  end
end
