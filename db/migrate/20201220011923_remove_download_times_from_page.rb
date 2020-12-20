class RemoveDownloadTimesFromPage < ActiveRecord::Migration[6.0]
  def change
    remove_column(:pages, :download_success, :datetime)
    remove_column(:pages, :download_failure, :datetime)
    remove_column(:pages, :download_invalid, :datetime)
  end
end
