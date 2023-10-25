class CheckoutsController < ApplicationController
    def create
        customer = Stripe::Customer.create({
            email: current_user.email,
        })

        session = Stripe::Checkout::Session.create({
        customer: customer.id,
        payment_method_types: ['card'],
        line_items: [{
            price: params.fetch("stripe_price_id"),
            quantity: 1,
        }],
        mode: 'payment',
        success_url: checkout_success_url,
        cancel_url: checkout_cancel_url,
      })

      redirect_to session.url, allow_other_host: true
    end

    def success
        redirect_to checkout_success_url, notice: "Purchase was successful!"
    end

    def cancel
        redirect_to checkout_cancel_url, notice: "Purchase was cancelled!"
    end

end