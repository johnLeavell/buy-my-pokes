class CartController < ApplicationController
    def show
    end

    def destroy
        session[:cart].delete(params[:product_id].to_s)
        load_cart
        redirect_to cart_path, notice: "Item removed from your cart."
    end
end
