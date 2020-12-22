class AddStatusesToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :refresh_status, :integer, default: 0
    add_column :pages, :parse_status, :integer, default: 0
    add_column :pages, :index_status, :integer, default: 0
    add_column :pages, :cache_status, :integer, default: 0

    add_index :pages, :refresh_status
    add_index :pages, :parse_status
    add_index :pages, :index_status
    add_index :pages, :cache_status
  end
end
