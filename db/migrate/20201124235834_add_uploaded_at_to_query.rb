class AddUploadedAtToQuery < ActiveRecord::Migration[6.0]
  def change
    add_column :queries, :cached_at, :datetime
  end
end
