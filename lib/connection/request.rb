module Connection
  class Request

    require 'net/http'

    attr_accessor :url, :port, :method, :response,  :uri, :net, :parser, :options, :http

    def initialize(method, url, options = {}, ssl=false, port=8080)
      @url = url
      @port = uri.port.nil?? port : uri.port
      @method = method.to_s
      @use_ssl = Rails.env.development?? false : ssl 
      @options = options
      @header = @options.delete(:header)
      @authentication = @options.delete(:authentication)
      @net = ::Net::HTTP
      @parser = ::JSON
    end

    def invoke
      begin
        @response = http.request(net_request)
      rescue => e
        puts e.message
      end
    end

    def success?
      if @response.present?
        @response.kind_of? Net::HTTPSuccess
      end
    end

    def response
      if @response.present?
        return parser.parse @response.response.body
      end
    end

    def header
      @header = @header.nil?? {'Content-Type' =>'application/json'} : @header
    end

    protected

      def uri
        ::URI.parse(url)
      end

      def http
        http = net.new uri.host, port
        http.use_ssl = use_ssl
        http
      end

      def net_http
        "::Net::HTTP::#{method.capitalize}".constantize
      end

      def net_request
        request = net_http.new(uri, header)
        request["Authorization"] = authentication if @authentication
        request.body = options[:params].to_json if options[:params].present?
        request
      end

      def use_ssl
        @use_ssl
      end

      def authentication
        if @authentication
          case @authentication[:type]
            when "HTTP Authentication Base64"
              return "Basic " + Base64::encode64("#{@authentication[:credential][:username]}:#{@authentication[:credential][:password]}").gsub("\n", "")
          end
        end
      end

  end
end