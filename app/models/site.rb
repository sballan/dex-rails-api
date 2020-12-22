class Site < ApplicationRecord
  validates_presence_of :home_url, :host
end
