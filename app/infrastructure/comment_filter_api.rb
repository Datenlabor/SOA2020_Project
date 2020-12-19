# frozen_string_literal: false

require 'http'
require 'json'
# require_relative 'comment'

module GetComment
  module Gateway
    # Infrastructure to call Our API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def get_comments(video_id)
        @request.get_comments(video_id)
      end

      def get_videos(video_list)
        @request.get_videos(video_list)
      end

      def add_video(video_id)
        @request.add_video(video_id)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def get_comments(video_id)
          call_api('get', ['comments', video_id])
        end

        def get_videos(video_list)
          call_api('get', ['videos'],
                   'list' => Value::WatchedList.to_encoded(video_list))
        end

        def add_video(video_id)
          call_api('post', ['comments', video_id])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299).freeze

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
