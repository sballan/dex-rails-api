class RemoveTimestampsFromLink < ActiveRecord::Migration[6.0]
  def change
    remove_column :links, :created_at, :datetime, precision: 6, null: false
    remove_column :links, :updated_at, :datetime, precision: 6, null: false
  end
end
