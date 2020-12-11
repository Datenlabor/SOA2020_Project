# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # show comments of a video
    class Comment
      include Dry::Transaction

      step :retrieve_comments
      step :reify_comments

      private

      def retrieve_comments
        result = Gateway::Api.new(GetComment::App.config).comments(input[:video_id])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        Failure('Cannot get comments right now; please try again later')
      end

      def reify_comments(comment_json)
        Representer::Comments.new(OpenStruct.new)
                             .from_json(comment_json)
                             .then { |comment| Success(comment) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end
    end
  end
end
