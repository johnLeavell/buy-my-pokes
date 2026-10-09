class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :initialize_session
    before_action :load_cart

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, :keys => [:username, :first_name, :last_name])

      devise_parameter_sanitizer.permit(:account_update, :keys => [:first_name, :last_name, :username])
    end

    private

    def initialize_session
        session[:cart] ||= {}
    end

    # Cart items as { product: Product, quantity: Integer }, skipping any
    # cart entries whose product no longer exists.
    def load_cart
        products = Product.where(id: session[:cart].keys).index_by { |product| product.id.to_s }

        @cart_items = session[:cart].filter_map do |product_id, quantity|
            product = products[product_id]
            { product: product, quantity: quantity } if product
        end

        @cart_total_cents = @cart_items.sum { |item| item[:product].price * item[:quantity] }
    end

    def require_admin!
        unless user_signed_in? && current_user.admin?
            redirect_to root_path, alert: "You are not authorized to do that."
        end
    end
end
