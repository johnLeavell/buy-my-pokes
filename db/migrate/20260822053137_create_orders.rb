class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_checkout_session_id
      t.string :status, null: false, default: "pending"
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: "usd"

      t.timestamps
    end

    add_index :orders, :stripe_checkout_session_id, unique: true
  end
end
