# == Schema Information
#
# Table name: products
#
#  id                :bigint           not null, primary key
#  currency          :string           default("usd")
#  name              :string
#  price             :integer
#  sales_count       :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_price_id   :string
#  stripe_product_id :string
#
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires a name" do
    product = Product.new(price: 1000)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "requires a positive price" do
    product = Product.new(name: "Squirtle", price: 0)
    assert_not product.valid?

    product.price = 1000
    assert product.valid?
  end

  test "rejects prices at or above the ceiling" do
    product = Product.new(name: "Mewtwo", price: 1_000_000)
    assert_not product.valid?
  end

  test "price_cents exposes a Money object in the product's currency" do
    product = products(:charizard)
    assert_equal Money.new(45_000, "usd"), product.price_cents
  end
end
