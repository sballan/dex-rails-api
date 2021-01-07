class AddIndexFragmentsToPageMeta < ActiveRecord::Migration[6.0]
  def change
    add_column :page_meta, :indexed_title, :boolean, default: false
    add_column :page_meta, :indexed_links, :boolean, default: false
    add_column :page_meta, :indexed_headers, :boolean, default: false
  end
end
