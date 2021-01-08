class RemoveTimestampsFromPage < ActiveRecord::Migration[6.0]
  def change
    remove_column :pages, :created_at, :datetime, precision: 6, null: false
    remove_column :pages, :updated_at, :datetime, precision: 6, null: false
  end
end
