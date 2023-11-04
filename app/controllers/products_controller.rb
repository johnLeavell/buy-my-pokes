class ProductsController < ApplicationController
    before_action :set_product, only: %i[ show update destroy ]

    def index
        @products = Stripe::Product.list({limit: 20})
    end

    def show

    end

    def new
        @product = Product.new
    end

    def create
        @product = Product.new(product_params)
        if @stripe_product.save
            redirect_to @product, notice: "Product was successfully created."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def add_to_cart
        id = params[:id].to_i
        session[:cart].push(id) unless session[:cart].include?(id)
        
        redirect_to products_path, notice: "Product was successfully added to cart."
    end

    def update
        if @product.update(product_params)
            redirect_to @product, notice: "Product was successfully updated."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @product.destroy
        redirect_to products_url, notice: "Product was successfully destroyed."
    end

    private

    def set_product
        @product = Product.find(params[:id])
    end

    def product_params
        params.require(:product).permit(:name, :price, :currency, :stripe_product_id, :stripe_price_id)
    end
end