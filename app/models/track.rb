class Track < ActiveRecord::Base

	belongs_to :trackable, polymorphic: true
	belongs_to :user

	validates :user, presence: true

end
