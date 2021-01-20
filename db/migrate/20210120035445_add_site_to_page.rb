class AddSiteToPage < ActiveRecord::Migration[6.1]
  def change
    add_reference(:pages, :site, foreign_key: :true, null: true)
  end
end
