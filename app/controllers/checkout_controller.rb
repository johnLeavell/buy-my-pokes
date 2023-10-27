class CheckoutController < ApplicationController
    def create
        session = Stripe::Checkout::Session.create({
        customer: current_user.stripe_customer.id,
        payment_method_types: ['card'],
        line_items: [{
            price: params.fetch("price"),
            quantity: 1,
        }],
        mode: 'payment',
        success_url: success_checkout_index_url,
        cancel_url: cancel_checkout_index_url,
      })

      redirect_to session.url, allow_other_host: true
    end

    def success;end

    def cancel;end

end