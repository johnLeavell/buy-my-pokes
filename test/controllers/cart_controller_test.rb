require "test_helper"

class CartControllerTest < ActionDispatch::IntegrationTest
  test "show renders even with an empty cart" do
    get cart_path
    assert_response :success
  end

  test "show lists items that were added to the cart" do
    product = products(:charizard)
    post add_to_cart_product_path(product)

    get cart_path
    assert_response :success
    assert_match product.name, response.body
  end

  test "destroy removes an item from the cart" do
    product = products(:charizard)
    post add_to_cart_product_path(product)

    delete remove_item_cart_path(product_id: product.id)

    assert_redirected_to cart_path
    assert_nil session[:cart][product.id.to_s]
  end
end
