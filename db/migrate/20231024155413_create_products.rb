class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :price
      t.string :stripe_product_id
      t.string :stripe_price_id
      t.string :currency, default: "usd"
      t.integer :sales_count, default: 0, null: false

      t.timestamps
    end
  end
end
