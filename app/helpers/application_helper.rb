module ApplicationHelper
  DEFAULT_TITLE = "Buy My Pokes | Authentic Pokémon Card Marketplace"
  DEFAULT_DESCRIPTION = "Buy and sell authentic Pokémon trading cards securely. Browse graded and raw cards, " \
    "add to cart, and check out safely with Stripe."

  def page_title
    content_for?(:title) ? "#{content_for(:title)} | Buy My Pokes" : DEFAULT_TITLE
  end

  def page_description
    content_for?(:description) ? content_for(:description) : DEFAULT_DESCRIPTION
  end

  def social_preview_image_url
    image_url("social-preview.png")
  end
end
