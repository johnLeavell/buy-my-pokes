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
class Product < ApplicationRecord
    has_many :order_items

    validates :name, presence: true
    validates :price, numericality: { greater_than: 0, less_than: 1000000 }
    validates :currency, inclusion: { in: %w[usd eur pln uah] }

    def to_s
        name
    end

    monetize :price, as: :price_cents
end
