module Imgurapi
  class Session
    HOST = 'https://api.imgur.com'

    # Creates the session instance that handles all the API calls to Imgur
    # access_token is optional
    def initialize(options)
      required_arguments = %i(client_id client_secret refresh_token)
      raise ArgumentError unless required_arguments.all? { |key| options.keys.include? key }

      @client_id = options[:client_id]
      @client_secret = options[:client_secret]
      @access_token = options[:access_token]
      @refresh_token = options[:refresh_token]
      @use_ssl = !!options[:use_ssl]
    end

    # Singleton initializer to allow access_token reuse
    def self.instance(options)
      @@session ||= new(options)
    end

    %w(Account Image).each do |clazz|
      define_method clazz.downcase do
        Imgurapi::Api.const_get(clazz).new(self)
      end
    end

    def use_ssl?
      @use_ssl
    end

    def access_token=(access_token)
      @access_token = access_token

      # Forces to create a new connection with new header
      @connection = nil
    end

    def params
      {
        refresh_token: @refresh_token,
        client_id:     @client_id,
        client_secret: @client_secret
      }
    end

    def connection
      @connection ||= Faraday.new(
        HOST,
        headers: {'Authorization' => 'Bearer ' << @access_token}
      )
    end
  end
end
