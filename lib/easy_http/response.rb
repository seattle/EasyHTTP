# encoding: UTF-8

module EasyHTTP
  class Response

    attr_reader :url, :status, :status_message, :body, :headers, :charset

    def initialize url, response, default_charset = nil
      default_charset = "ASCII-8BIT" unless default_charset
      @url = url

      @status = response.code.to_i
      @status_message = response.message

      @body = response.body.encode default_charset

      @headers = {}
      response.each_header { |k, v| @headers[k] = v}
      if response['Content-type'].nil?
        @charset =  default_charset
      else
        @charset = determine_charset(response['Content-type'], response.body) || default_charset
      end
    end

    def inspect
      "#<EasyHTTP::Response @status_message='#{@status_message}'>"
    end

    private

    def determine_charset(header_data, body)
      header_data.match(charset_regex) || (body && body.match(charset_regex))
      $1
    end

    def charset_regex
      /(?:charset|encoding)="?([a-z0-9-]+)"?/i
    end

  end
end
