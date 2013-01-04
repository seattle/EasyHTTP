# encoding: UTF-8

module EasyHTTP
  class Session
    # Net:HTTP object
    attr_accessor :http

    # Base URL
    attr_accessor :base_url

    # Default headers
    attr_accessor :default_headers

    # URI Objet for requests
    attr_accessor :uri

    # Options sent to the constructor
    attr_accessor :options

    # Session Cookies
    attr_accessor :cookies

    # HTTP Auth credentials
    attr_accessor :username, :password

    # Default request charset
    attr_accessor :default_response_charset

    def initialize url, options = {}
      @cookies = nil # Initialize cookies store to nil
      @default_headers = {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.101 Safari/537.11'
      } # Initialize default headers
      @options = options # Store Options

      # Store base URL
      @base_url = url.match(/^http/) ? url : "#{@options[:ssl] ? 'https' : 'http'}://#{url}"

      unless options[:port].nil?
        @base_url = "#{@base_url}:#{options[:port]}" unless @base_url.match(/":#{options[:port]}"^/)
      end

      # Store credentials
      @username = options[:username] unless options[:username].nil?
      @password = options[:password] unless options[:password].nil?

      @uri = URI(@base_url) # Parse URI Object

      create_ua
    end

    def create_ua
      # Create the Session Object
      @http = Net::HTTP.new(uri.host, uri.port)

      # Set passed read timeout
      @http.read_timeout = options[:read_timeout] ||= 1000

      # Enable debug output
      @http.set_debug_output options[:debug]  unless options[:debug].nil?

      # Enable SSL if necessary
      @http.use_ssl = true if @options[:ssl]

      # Allow work with insecure servers
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @options[:insecure]
    end

    # Initialize store cookies for this session
    def session_cookies
      @cookies = {}
    end

    # Method for GET request
    def get path, query = nil, headers = {}
      send_request :get, path, headers, :query => query
    end

    # Method for POST request
    def post path, data, headers = {}
      headers['Content-Type'] = 'application/x-www-form-urlencoded' if headers['Content-Type'].nil?
      send_request :post, path, headers, :data => data
    end

    # Send an HTTP request
    def send_request action, path, headers, request_options = {}
      # Parse path to prevent errors
      path = "/#{path}" unless path.match(/^"\/"/)

      # Create the request
      case action
      when :get
        # Create a GET method
        request = Net::HTTP::Get.new(path)
      when :post
        # Create a POST method
        request = Net::HTTP::Post.new(path)

        # Set data to send
        if request_options[:data].is_a?(Hash)
          request.set_form_data request_options[:data]
        elsif request_options[:data].is_a?(String)
          request.body = request_options[:data]
        end

      else
        # Raises exception?¿
      end

      unless request.nil?
        # Enable auth if user parameter is set on constructor
        request.basic_auth(@username, @password) unless @username.nil?

        # Set rdefault and equest headers
        @default_headers.each { |k,v| request[k] = v}
        headers.each { |k,v| request[k] = v}

        # If we have activated store cookie, we define it for the request
        unless @cookies.nil?
          request['Cookie'] = request['Cookie'].nil? ? format_cookies : [request['Cookie'], format_cookies].join("; ")
        end
        # make request
        response = http.request(request)

        unless response.nil?
          # Store cookies if have enabled store it
          handle_cookies response unless @cookies.nil?
          # Generate and return response
          return Response.new "#{base_url}#{path}", response, @default_response_charset
        end
      end
    end

    def marshal_dump
      [ @base_url, @default_headers, @uri, @options, @cookies , @username, @password, @default_response_charset ]
    end

    def marshal_load data
      @base_url, @default_headers, @uri, @options, @cookies , @username, @password, @default_response_charset = data
      create_ua
    end

    private
    def handle_cookies response
      # CGI don't understand this parameters
      bad_keys = ['path', 'Path', 'expires', 'Expires']

      # If at the request has sent a cookie we store it
      unless response['set-cookie'].nil?
        # Get cookies in the header
        parsed_cookies = CGI::Cookie::parse response['set-cookie']

        # Remove unnecessary values
        bad_keys.each { |key| parsed_cookies.delete(key) }

        # Store the cookies
        parsed_cookies.each do |k,v|
          cookie_parts  = v.to_s.split(";")[0].split("=")
          @cookies[cookie_parts[0]] = URI.unescape(cookie_parts[1])
        end
      end
    end

    def format_cookies
      (@cookies.collect{ |k,v| "#{k}=#{v}"}).join("; ")
    end
  end
end
