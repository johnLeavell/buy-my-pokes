class CheckoutController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_cart_present, only: :create

    def create
        checkout_session = Stripe::Checkout::Session.create({
            customer: current_user.stripe_customer.id,
            payment_method_types: ["card"],
            line_items: line_items_for_cart,
            mode: "payment",
            success_url: "#{success_checkout_index_url}?session_id={CHECKOUT_SESSION_ID}",
            cancel_url: cancel_checkout_index_url,
            metadata: {
                user_id: current_user.id,
                cart: session[:cart].to_json,
            },
        })

        redirect_to checkout_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
        redirect_to cart_path, alert: "We couldn't start checkout: #{e.message}"
    end

    def success
        session[:cart] = {}
    end

    def cancel
    end

    private

    def ensure_cart_present
        if @cart_items.blank?
            redirect_to cart_path, alert: "Your cart is empty."
        elsif @cart_items.map { |item| item[:product].currency }.uniq.size > 1
            redirect_to cart_path, alert: "Your cart has items in different currencies. Please checkout one currency at a time."
        end
    end

    def line_items_for_cart
        @cart_items.map do |item|
            {
                price_data: {
                    currency: item[:product].currency,
                    product_data: { name: item[:product].name },
                    unit_amount: item[:product].price,
                },
                quantity: item[:quantity],
            }
        end
    end
end
