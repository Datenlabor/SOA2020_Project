# frozen_string_literal: true

require 'dry/monads'

module GetComment
  module Service
    # list a video
    class ListVideos
      include Dry::Transaction

      step :get_api_list
      step :reify_list

      private

      def get_api_list(video_list)
        result = Gateway::Api.new(GetComment::App.config).video_list(video_list)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot access api')
      end

      def reify_list(videos_json)
        Representer::VideosList.new(OpenStruct.new)
                               .from_json(videos_json)
                               .then{ |videos| Success(videos) }
      rescue StandardError
        Failure('Cannot parse response from api')
      end
    end
  end
end
