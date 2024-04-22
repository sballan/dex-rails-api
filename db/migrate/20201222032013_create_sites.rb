class CreateSites < ActiveRecord::Migration[6.0]
  def change
    create_table :sites do |t|
      t.string :home_url, null: false
      t.string :host, null: false
      t.boolean :scrape_active, default: false

      t.string :refresh_job_id, default: nil
      t.datetime :refresh_job_started_at

      t.timestamps
    end

    add_index(:sites, :home_url, unique: true)
    add_index(:sites, :host, unique: true)
  end
end
