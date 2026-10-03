require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index is public" do
    get products_path
    assert_response :success
  end

  test "show is public" do
    get product_path(products(:charizard))
    assert_response :success
  end

  test "guests cannot reach the new product form" do
    get new_product_path
    assert_redirected_to root_path
  end

  test "non-admin users cannot reach the new product form" do
    sign_in users(:shopper)
    get new_product_path
    assert_redirected_to root_path
  end

  test "admins can create a product" do
    sign_in users(:store_admin)

    assert_difference "Product.count", 1 do
      post products_path, params: { product: { name: "Blastoise", price: 12_000, currency: "usd" } }
    end

    assert_redirected_to product_path(Product.last)
  end

  test "invalid product creation re-renders the form" do
    sign_in users(:store_admin)

    assert_no_difference "Product.count" do
      post products_path, params: { product: { name: "", price: 12_000 } }
    end

    assert_response :unprocessable_entity
  end

  test "non-admins cannot delete a product" do
    sign_in users(:shopper)

    assert_no_difference "Product.count" do
      delete product_path(products(:charizard))
    end

    assert_redirected_to root_path
  end

  test "admins can delete a product" do
    sign_in users(:store_admin)
    product = products(:pikachu)

    assert_difference "Product.count", -1 do
      delete product_path(product)
    end
  end

  test "add_to_cart adds the product to the session cart" do
    product = products(:charizard)

    post add_to_cart_product_path(product)

    assert_redirected_to products_path
    assert_equal 1, session[:cart][product.id.to_s]
  end

  test "add_to_cart increments quantity on repeat adds" do
    product = products(:charizard)

    post add_to_cart_product_path(product)
    post add_to_cart_product_path(product)

    assert_equal 2, session[:cart][product.id.to_s]
  end
end
