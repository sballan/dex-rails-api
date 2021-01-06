class RemoveStatusesFromPages < ActiveRecord::Migration[6.0]
  def change
    remove_index :pages, :refresh_status
    remove_index :pages, :parse_status
    remove_index :pages, :index_status
    remove_index :pages, :cache_status

    remove_column :pages, :refresh_status, :integer, default: 0
    remove_column :pages, :parse_status, :integer, default: 0
    remove_column :pages, :index_status, :integer, default: 0
    remove_column :pages, :cache_status, :integer, default: 0
  end
end
