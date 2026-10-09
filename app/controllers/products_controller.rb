class ProductsController < ApplicationController
    before_action :set_product, only: %i[ show edit update destroy ]
    before_action :require_admin!, only: %i[ new create edit update destroy ]

    def index
        @products = Product.order(created_at: :desc)
    end

    def show
    end

    def new
        @product = Product.new
    end

    def create
        @product = Product.new(product_params)
        if @product.save
            redirect_to @product, notice: "Product was successfully created."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def add_to_cart
        product = Product.find_by(id: params[:id])

        if product
            session[:cart][product.id.to_s] = session[:cart].fetch(product.id.to_s, 0) + 1
            redirect_to products_path, notice: "#{product.name} was added to your cart."
        else
            redirect_to products_path, alert: "That product could not be found."
        end
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
        params.require(:product).permit(:name, :price, :currency)
    end
end
