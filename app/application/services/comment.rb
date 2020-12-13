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

      def retrieve_comments(input)
        result = Gateway::Api.new(GetComment::App.config).get_comments(input[:video_id])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot get comments right now; please try again later')
      end

      def reify_comments(comment_json)
        # puts comment_json
        Representer::CommentsList.new(OpenStruct.new)
                                 .from_json(comment_json)
                                 .then { |comment| Success(comment) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end
    end
  end
end
