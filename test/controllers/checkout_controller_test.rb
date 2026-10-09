require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  test "guests are redirected to sign in" do
    post checkout_index_path
    assert_redirected_to new_user_session_path
  end

  test "an empty cart redirects back with an alert" do
    sign_in users(:shopper)

    post checkout_index_path

    assert_redirected_to cart_path
    assert_equal "Your cart is empty.", flash[:alert]
  end

  test "mixed currencies in the cart are rejected" do
    sign_in users(:shopper)
    eur_product = Product.create!(name: "Mew (EU release)", price: 5_000, currency: "eur")

    post add_to_cart_product_path(products(:charizard))
    post add_to_cart_product_path(eur_product)

    post checkout_index_path

    assert_redirected_to cart_path
    assert_match "different currencies", flash[:alert]
  end

  test "a valid cart starts a Stripe checkout session and redirects to it" do
    user = users(:shopper)
    sign_in user

    post add_to_cart_product_path(products(:charizard))

    fake_customer = Struct.new(:id).new("cus_123")
    fake_session = Struct.new(:url).new("https://checkout.stripe.com/pay/cs_test_123")

    Stripe::Customer.stub :create, fake_customer do
      Stripe::Checkout::Session.stub :create, fake_session do
        post checkout_index_path
      end
    end

    assert_redirected_to fake_session.url
  end
end
