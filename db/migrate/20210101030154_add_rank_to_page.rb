class AddRankToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :rank, :decimal
  end
end
