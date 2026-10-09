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
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  monetize :total_cents

  validates :status, inclusion: { in: %w[pending paid canceled] }
end
