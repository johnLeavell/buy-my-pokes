xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  @static_paths.each do |path|
    xml.url do
      xml.loc "#{request.base_url}#{path}"
    end
  end

  @products.each do |product|
    xml.url do
      xml.loc "#{request.base_url}#{product_path(product)}"
      xml.lastmod product.updated_at.iso8601
    end
  end
end
