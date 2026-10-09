class SitemapsController < ActionController::Base
    def robots
        render plain: <<~TEXT, content_type: "text/plain"
            User-agent: *
            Disallow: /cart
            Disallow: /checkout
            Disallow: /orders
            Disallow: /users/
            Allow: /

            Sitemap: #{request.base_url}/sitemap.xml
        TEXT
    end

    def sitemap
        @products = Product.order(created_at: :desc)
        @static_paths = [
            root_path,
            about_path,
            products_path,
            privacy_path,
            terms_path,
            new_user_registration_path,
        ]

        render layout: false
    end
end
