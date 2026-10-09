class Webhooks::StripeController < ActionController::API
  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: e.message }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400
      return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_session_completed(event.data.object)
    else
      Rails.logger.info("Unhandled Stripe event type: #{event.type}")
    end

    head :ok
  end

  private

  def handle_checkout_session_completed(checkout_session)
    return if Order.exists?(stripe_checkout_session_id: checkout_session.id)

    user = User.find_by(id: checkout_session.metadata["user_id"])
    return unless user

    cart = JSON.parse(checkout_session.metadata["cart"] || "{}")

    order = user.orders.create!(
      stripe_checkout_session_id: checkout_session.id,
      status: "paid",
      total_cents: checkout_session.amount_total,
      currency: checkout_session.currency,
    )

    cart.each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      order.order_items.create!(
        product: product,
        name: product.name,
        unit_price_cents: product.price,
        quantity: quantity,
      )
      product.increment!(:sales_count, quantity)
    end
  end
end
