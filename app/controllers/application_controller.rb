class ApplicationController < ActionController::Base
    # before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :initialize_session
    before_action :load_cart

        
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, :keys => [:username, :first_name, :last_name])
        
      devise_parameter_sanitizer.permit(:account_update, :keys => [:first_name, :last_name, :username])
    end

    private
    
    def initialize_session
        session[:cart] ||= []
    end

    def load_cart
        @cart = Product.where(id: session[:cart])
    end
end
