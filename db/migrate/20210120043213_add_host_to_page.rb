class AddHostToPage < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :host, :string
  end
end
