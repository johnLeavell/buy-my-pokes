# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :citext
#  last_name              :citext
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :citext
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "full_name combines first and last name" do
    user = users(:shopper)
    assert_equal "Sam Shopper", user.full_name
  end

  test "regular users are not admin" do
    assert_not users(:shopper).admin?
  end

  test "admin users report admin?" do
    assert users(:store_admin).admin?
  end
end
