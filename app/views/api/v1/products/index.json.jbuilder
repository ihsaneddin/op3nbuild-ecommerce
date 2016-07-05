json.array! @products do |product|
  json.contractor_slug product.contractor.slug
  json.edit_url admin_merchandise_product_url(product)
  json.name product.name
  json.price number_to_currency product.price
  json.description product.description
  json.description_markup product.description_markup
  json.url market_places_product_url(product, {contractor: product.contractor.slug})
  json.product_type product.product_type.name
  json.image_url product.newest_image_url 
end