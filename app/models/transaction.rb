class Transaction < ApplicationRecord
  enum kind: { seed: 0, c: 1, d: 2 }
  validates :description, presence: true
  validates :amount, numericality: {only_integer: true}
end
