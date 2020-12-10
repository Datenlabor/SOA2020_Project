# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class AddVideo
      include Dry::Transaction
      step :parse_url
      step :request_video
      step :reify_video

      private

      # Helper function for extracting video_id from YouTube url
      def parse_url(input)
        if input.success?
          video_id = youtube_id(input[:youtube_url])
          Success(video_id: video_id)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def request_video(input)
        result = Gateway::Api.new(GetComment::App.config).add_video(input[:video_id])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
        Failure('Cannot add projects right now; please try again later')
      end

      def reify_video(video_json)
        Representer::Video.new(OpenStruct.new)
          .from_json(video_json)
          .then { |video| Success(video) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end

      # following are support methods that other services could use

      def youtube_id(youtube_url)
        regex = %r{(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?)/|\S*?[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
        match = regex.match(youtube_url)
        match[1] if match
      end
    end
  end
end
