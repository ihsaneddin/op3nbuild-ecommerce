module EcommerceCredentials
  class Application < Rails::Application
    #config.before_configuration do
      ecommerce_credentials_file = Rails.root.join("config", 'openbuild.yml').to_s

      if File.exists?(ecommerce_credentials_file)
        YAML.load_file(ecommerce_credentials_file)[Rails.env].each do |key, value|
          ENV[key] = value
        end
      end
    #end
  end
end