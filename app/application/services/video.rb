# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class Video
      include Dry::Transaction
      step :parse_url

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

      # following are support methods that other services could use

      def youtube_id(youtube_url)
        regex = %r{(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?)/|\S*?[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
        match = regex.match(youtube_url)
        match[1] if match
      end
    end
  end
end
