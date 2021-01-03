class ChangeColumnDefaultQueryCachedAt < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:queries, :cached_at, from: nil, to: DateTime.new(0))
  end
end
