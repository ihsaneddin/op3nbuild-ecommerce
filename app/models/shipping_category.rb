class ShippingCategory < ActiveRecord::Base

	DEFAULTS= ['Light Item', 'Heavy Item']

  has_many :products
  has_many :shipping_rates

  validates :name, presence: true, length: { maximum: 255 }
end
