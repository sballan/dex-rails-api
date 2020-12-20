class AddStartAndFinishTimesToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :refresh_started_at, :datetime
    add_column :pages, :refresh_finished_at, :datetime
    add_column :pages, :parse_started_at, :datetime
    add_column :pages, :parse_finished_at, :datetime
    add_column :pages, :index_started_at, :datetime
    add_column :pages, :index_finished_at, :datetime
    add_column :pages, :cache_started_at, :datetime
    add_column :pages, :cache_finished_at, :datetime
  end
end
