class AddLinkIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :links, %i[to_id from_id text], unique: true
  end
end
