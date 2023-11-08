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
    validates :name, presence: true
    validates :price, numericality: { greater_than: 0, less_than: 1000000 }

    def to_s
        name
    end
    
    monetize :price, as: :price_cents

    # i need to make a shopping cart that will add the items to the cart and then checkout,
    # i need to make a checkout page that will show the items in the cart and then allow the user to checkout
    # i need to make a checkout page that will allow the user to checkout and then pay for the items

end
