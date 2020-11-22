class Query < ApplicationRecord
  has_many :results
  has_many :pages, through: :results
end
