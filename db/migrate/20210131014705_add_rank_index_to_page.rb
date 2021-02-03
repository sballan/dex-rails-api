class AddRankIndexToPage < ActiveRecord::Migration[6.1]
  def change
    add_index :pages, :rank
  end
end
