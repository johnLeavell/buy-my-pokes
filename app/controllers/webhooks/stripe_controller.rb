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
            status 400
            return
        rescue Stripe::SignatureVerificationError => e
            # Invalid signature
            status 400
            return
        end

        # Handle the event
        case event.type
        when 'checkout.session.completed'
            session = event.data.object
            # Fulfill the purchase...
            handle_checkout_session(session)
        when 'invoice.paid'
            invoice = event.data.object
            handle_invoice_paid(invoice)
        when 'invoice.payment_failed'
            invoice = event.data.object
            handle_invoice_payment_failed(invoice)
        # ... handle other event types
        else
            # Unexpected event type
            status 400
            return
        end
        
    end

end
