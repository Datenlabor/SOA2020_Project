# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class AddVideo
      include Dry::Transaction
      step :validate_video
      step :request_video
      step :reify_video

      private

      # Helper function for extracting video_id from YouTube url
      def validate_video(input)
        if input[:watched_list].include? input[:video_id]
          Success(input)
        else
          Failure('Please first request this project to be added to your list')
        end
      end

      def request_video(input)
        input[:response] = Gateway::Api.new(GetComment::App.config).add_video(input[:video_id])
        input[:response].success? ? Success(input) : Failure(input[:response].message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot add projects right now; please try again later')
      end

      def reify_video(input)
        unless input[:response].processing?
          Representer::Video.new(OpenStruct.new)
                            .from_json(input[:response].payload)
                            .then { input[:analyzed] = _1 }
        end
        Success(input)
      rescue StandardError
        Failure('Error in the video -- please try again')
      end
    end
  end
end
