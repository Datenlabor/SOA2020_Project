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
        input[:response] = Gateway::Api.new(GetComment::App.config).get_comments(input[:video_id])
        input[:response].success? ? Success(input) : Failure(input[:response].message)
      rescue StandardError
        Failure('Cannot get comments right now; please try again later')
      end

      def reify_comments(input)
        unless input[:response].processing?
          Representer::CommentsList.new(OpenStruct.new)
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
