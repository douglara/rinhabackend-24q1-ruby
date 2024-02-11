class Transaction < ApplicationRecord
  enum kind: { seed: 0, c: 1, d: 2 }
end
