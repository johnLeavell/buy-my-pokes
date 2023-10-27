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
  # test "the truth" do
  #   assert true
  # end
end
