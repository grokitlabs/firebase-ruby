require 'typhoeus'
require 'json'
require 'uri'

module Firebase
  class Request

    class << self

      def get(path)
        process(:get, path)
      end

      def put(path, value)
        process(:put, path, :body => value.to_json)
      end

      def post(path, value)
        process(:post, path, :body => value.to_json)
      end

      def delete(path)
        process(:delete, path)
      end

      def build_url(path)
        host = Firebase.base_uri
        path = "#{path}.json"
        query_string = Firebase.key ? "?key=#{Firebase.key}" : ""
        url = URI.join(Firebase.base_uri, path, query_string)

        url.to_s
      end

      private

      def process(method, path, options={})
        raise "Please set Firebase.base_uri before making requests" unless Firebase.base_uri

        request = Typhoeus::Request.new(build_url(path),
                                        :body => options[:body],
                                        :method => method)
        hydra = Typhoeus::Hydra.new
        hydra.queue(request)
        hydra.run

        new request.response
      end

    end

    attr_accessor :response

    def initialize(response)
      @response = response
    end

    def body
      JSON.parse(response.body)
    end

    def raw_body
      response.body
    end

    def success?
      response.code.in? [200, 204]
    end

    def code
      response.code
    end

  end
end
