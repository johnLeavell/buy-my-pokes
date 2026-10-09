# == Schema Information
#
# Table name: order_items
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  quantity         :integer          default(1), not null
#  unit_price_cents :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :bigint           not null
#  product_id       :bigint
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_id => products.id) ON DELETE => nullify
#
require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "subtotal_cents multiplies unit price by quantity" do
    item = order_items(:shopper_order_charizard)
    item.quantity = 3
    assert_equal item.unit_price_cents * 3, item.subtotal_cents
  end

  test "surviving product deletion keeps the historical line item" do
    item = order_items(:shopper_order_charizard)
    products(:charizard).destroy

    item.reload
    assert_nil item.product_id
    assert_equal "Charizard", item.name
  end
end
