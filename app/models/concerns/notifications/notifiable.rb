module Notifications
	module Notifiable
		extend ActiveSupport::Concern
		included do 
			include Rails.application.routes.url_helpers
		end

			module ClassMethods
				
				def can_be_notified options = {}
					default_options = {sender_notification: nil, recipients_notification: nil, notification_yaml_text: nil, notifiable_attributes: [], notification_on: [:after_create, :around_update]}
					options = default_options.merge options
					if options[:recipients_notification].is_a?(Array) or options[:recipients_notification].is_a?(Symbol)
						options.each do |key, val|
							#model = self
							#included model do 
								self.class_attribute key
								self.send("#{key}=", val)
							#end							
						end
						set_notification_relation
						set_notification_callbacks options
					end 	
				end

				protected

					def set_notification_relation
						has_many :notifications, as: :notifiable, dependent: :destroy, class_name: 'Notification'
					end

					def set_notification_callbacks options ={}
						if options[:notification_on] and ( options[:notification_on].is_a?(Array) or options[:notification_on].is_a?(Symbol))
							options[:notification_on].respond_to?(:each) ? options[:notification_on].each {|call| send(call, :create_notification)} : send(options[:notification_on], :create_notification) 
						end
					end

			end

			def create_notification
				if notification_sender.present? and notification_text.present?
					notification_params = { subject: notification_text, sender: notification_sender }
					new_notification= self.notifications.new notification_params
					new_notification.receipts << notification_recipients
					new_notification.save
				end
				yield if block_given?
			end

			def notification_recipients
				get_recipients_notification
			end

			def get_recipients_notification methods = []
				methods= self.class.recipients_notification if methods.blank?
				recipient_brad=nil
				recipient_brad= methods.kind_of?(Array) ? recipients_notification.each{|r| recipient_brad= recipient_brad.nil?? self.send(r) : recipient_brad.send(r) } : self.send(methods)
				recipient_brad
			end

			def notification_sender
				get_sender_notification
			end

			def get_sender_notification methods = []
				methods= self.class.sender_notification if methods.blank?
				get_recipients_notification methods								
			end

			def notification_text 
				@notification_text ||= get_notification_text
			end

			def get_notification_text
				if self.class.notification_yaml_text.nil?
					notif_text_key = "notifications.#{self.class.name.demodulize.downcase}.#{callback_state}"
					default_title = []

					if self.notifiable_attributes.present?# and callback_state.eql?(:after_update)
						title = []
						@current_notifiable_attributes ||= self.notifiable_attributes.dup
						@notifiable_attributes_with_values ||= @current_notifiable_attributes.last.is_a?(Hash) ? @current_notifiable_attributes.pop : @notifiable_attributes_with_values

						@current_notifiable_attributes.each do |att|
							if self.send("#{att}_changed?")
								title << "#{notif_text_key}.subject.notifiable_attributes.#{att}"
							end
						end

						@notifiable_attributes_with_values.each do |att, val|
							if send("#{att}_changed?")
								current_att_val= self.send("#{att}")
								val = [val] unless val.is_a? Array
								if val.include? current_att_val
									title << "#{notif_text_key}.subject.notifiable_attributes.#{att}.#{current_att_val}"
									val.delete(current_att_val)
								end
							end
							@notifiable_attributes_with_values[att]= val
						end
						default_title= title
					else
						default_title = ["#{notif_text_key}.subject.default"]
					end
					default_title= default_title.map{|nt| I18n.t(nt, sender: notification_sender.try(:display_name)) }.join(' and ')
				else
					default_title= send self.class.notification_yaml_text
				end

				default_title
			end

			def callback_state
				id_changed?? :after_create : :after_update
			end

	end
end