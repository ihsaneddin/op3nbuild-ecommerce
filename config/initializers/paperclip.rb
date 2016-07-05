Paperclip.options[:command_path] = "/usr/local/bin"

unless Rails.env.development?
	Paperclip::Attachment.default_options.merge!(
		url: ':s3_domain_url',
		path: '/:class/:attachment/:id_partition/:style/:filename',
		storage: :s3,
		use_timestamp: false,
		s3_host_name: 's3-us-west-2.amazonaws.com',
		s3_permissions: :public_read,
		s3_protocol: 'http',
		s3_options: {
			server_side_encryption: 'AES256',
			storage_class: :reduced_redundancy,
			content_disposition: 'attachment'
			},
		s3_credentials: {
			bucket: ENV['FOG_DIRECTORY'],
			access_key_id: ENV['AW3_ACCESS_KEY_ID'],
			secret_access_key: ENV['AW3_SECRET_ACCESS_KEY']
			}
		)
end