class Webhooks::StripeController < ActionController::API
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { error: e.message }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event based on your application's logic
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object # contains a Stripe::PaymentIntent
      puts "Payment for #{payment_intent['amount']} succeeded."
      # Handle the successful payment intent, you can call a method to process it.
      # handle_payment_intent_succeeded(payment_intent)
    when 'payment_method.attached'
      payment_method = event.data.object # contains a Stripe::PaymentMethod
      # Handle the successful attachment of a PaymentMethod, if needed.
      # handle_payment_method_attached(payment_method)
    else
      puts "Unhandled event type: #{event.type}"
    end

    # Respond with a 200 status code to acknowledge receipt of the webhook
    head :ok
  end
end
