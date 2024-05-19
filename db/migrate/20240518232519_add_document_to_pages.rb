class AddDocumentToPages < ActiveRecord::Migration[7.1]
  def change
    add_reference :pages, :document, foreign_key: true
  end
end
