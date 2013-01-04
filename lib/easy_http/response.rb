# encoding: UTF-8

module EasyHTTP
  class Response

    attr_reader :url, :status, :status_message, :body, :headers, :charset

    def initialize url, response, default_charset = nil
      default_charset = "ASCII-8BIT" unless default_charset
      @url = url
      @status = response.code.to_i
      @status_message = response.message
      if response["content-type"]
        @charset = determine_charset(response['content-type'], response.body) || default_charset
      end
      @charset = default_charset if @charset.nil?
      @body = response.body

      if response["content-type"] && response["content-type"][0, 5] == "text/"
        convert_to_default_encoding! @body
      end

      @headers = {}
      response.each_header { |k, v| @headers[k] = convert_to_default_encoding! v }

      self
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

    def convert_to_default_encoding!(str)
      if str.respond_to?(:encode) && Encoding.default_internal
        str.force_encoding(charset).encode!(Encoding.default_internal)
      end
    end

  end
end
