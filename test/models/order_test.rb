# == Schema Information
#
# Table name: orders
#
#  id                         :bigint           not null, primary key
#  currency                   :string           default("usd"), not null
#  status                     :string           default("pending"), not null
#  total_cents                :integer          default(0), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  stripe_checkout_session_id :string
#  user_id                    :bigint           not null
#
# Indexes
#
#  index_orders_on_stripe_checkout_session_id  (stripe_checkout_session_id) UNIQUE
#  index_orders_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "valid statuses are restricted to a known set" do
    order = orders(:shopper_order)
    order.status = "refunded"
    assert_not order.valid?

    order.status = "paid"
    assert order.valid?
  end

  test "destroying an order destroys its order items" do
    order = orders(:shopper_order)
    assert_difference "OrderItem.count", -1 do
      order.destroy
    end
  end
end
