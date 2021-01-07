class AddIndexFragmentsToPageMeta < ActiveRecord::Migration[6.0]
  def change
    add_column :page_meta, :indexed_title, :boolean
    add_column :page_meta, :indexed_links, :boolean
    add_column :page_meta, :indexed_headers_, :boolean
  end
end
