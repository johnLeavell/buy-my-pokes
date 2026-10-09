require "test_helper"

class Webhooks::StripeControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["STRIPE_WEBHOOK_SECRET"] ||= "whsec_test"
  end

  def stub_event(type, object)
    fake_event = Struct.new(:type, :data).new(type, Struct.new(:object).new(object))
    Stripe::Webhook.stub :construct_event, fake_event do
      yield
    end
  end

  test "an invalid signature is rejected" do
    Stripe::Webhook.stub :construct_event, ->(*) { raise Stripe::SignatureVerificationError.new("bad sig", "sig") } do
      post webhooks_stripe_path, params: "{}", headers: { "Stripe-Signature" => "bad" }
    end

    assert_response :bad_request
  end

  test "checkout.session.completed creates an order and order items" do
    user = users(:shopper)
    product = products(:charizard)

    checkout_session = Struct.new(:id, :metadata, :amount_total, :currency).new(
      "cs_test_new_order",
      { "user_id" => user.id.to_s, "cart" => { product.id.to_s => 2 }.to_json },
      product.price * 2,
      product.currency,
    )

    assert_difference [ "Order.count", "OrderItem.count" ], 1 do
      stub_event("checkout.session.completed", checkout_session) do
        post webhooks_stripe_path, params: "{}", headers: { "Stripe-Signature" => "sig" }
      end
    end

    assert_response :success

    order = Order.find_by(stripe_checkout_session_id: "cs_test_new_order")
    assert order.present?
    assert_equal "paid", order.status
    assert_equal product.price * 2, order.total_cents
    assert_equal 2, order.order_items.sole.quantity
    assert_equal 2, product.reload.sales_count
  end

  test "the same checkout session is only processed once" do
    user = users(:shopper)
    product = products(:charizard)

    checkout_session = Struct.new(:id, :metadata, :amount_total, :currency).new(
      "cs_test_duplicate",
      { "user_id" => user.id.to_s, "cart" => { product.id.to_s => 1 }.to_json },
      product.price,
      product.currency,
    )

    stub_event("checkout.session.completed", checkout_session) do
      post webhooks_stripe_path, params: "{}", headers: { "Stripe-Signature" => "sig" }
    end

    assert_no_difference [ "Order.count", "OrderItem.count" ] do
      stub_event("checkout.session.completed", checkout_session) do
        post webhooks_stripe_path, params: "{}", headers: { "Stripe-Signature" => "sig" }
      end
    end
  end

  test "unhandled event types are acknowledged without side effects" do
    checkout_session = Struct.new(:id).new("evt_ignored")

    assert_no_difference "Order.count" do
      stub_event("payment_method.attached", checkout_session) do
        post webhooks_stripe_path, params: "{}", headers: { "Stripe-Signature" => "sig" }
      end
    end

    assert_response :success
  end
end
