module Openbuild
  class User

    attr_accessor :access_token, :authentication_token

    def initialize attributes = {}

      @access_token = attributes.delete :access_token
      @authentication_token = attributes.delete :authentication_token

      set_attribute_accessors attributes
    end

    def set_attribute_accessors attrs = {}
      attrs.each do |attri, value|
        self.class.send(:attr_accessor, attri)
        self.send(attri+'=', value)
      end
    end


  end
end