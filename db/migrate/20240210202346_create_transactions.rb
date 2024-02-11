class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.integer :customer_id, null: false
      t.integer :customer_limit_cents, null: false, limit: 8
      t.integer :customer_balance_cents, null: false, limit: 8

      t.integer :amount, null: false, limit: 8
      t.integer :kind, null: false
      t.string :description, null: false, limit: 10

      t.timestamps
    end
  end
end
