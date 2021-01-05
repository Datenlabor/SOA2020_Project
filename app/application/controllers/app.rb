# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module GetComment
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', js: 'main.js',
                    path: 'app/presentation/assets'
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        # Get viewer's previously seen videos from session
        session[:watching] ||= []
        view 'home'
      end

      routing.on 'history' do
        # Get videos from sessions
        puts "==DEBUG== Data in session is: #{session[:watching]}"

        result = Service::ListVideos.new.call(session[:watching])
        if result.failure?
          flash[:error] = result.failure
          video_list = []
        else
          videos = result.value!
          flash.now[:notice] = 'Let\'s Go Search!' if videos.none?
          video_list = Views::AllVideos.new(videos[:videos])
        end

        view 'history', locals: { videos: video_list }
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            video = Service::Video.new.call(url_request)

            if video.failure?
              flash[:error] = video.failure
              routing.redirect '/'
            end

            video = video.value!
            puts video[:video_id]
            session[:watching].insert(0, video[:video_id]).uniq!
            routing.redirect "comments/#{video[:video_id]}"
          end
        end

        routing.on String do |video_id|
          # GET /comment/{video_id}/
          routing.get do
            # Load comments
            video_made = Service::AddVideo.new.call(video_id: video_id)
            if video_made.failure?
              flash[:error] = video_made.failure
              routing.redirect '/'
            end

            video = video_made.value!
            if video.response.processing?
              flash[:notice] = 'Comments are analyzing, please try again later.'
            end
            result = Service::Comment.new.call(video_id: video.video_id)
            puts "==DEBUG== result.failure: #{result.failure}"
            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/'
            end
            yt_comments = OpenStruct.new(result.value!)
            if yt_comments.response.processing?
              flash[:notice] = 'Comments are analyzing, please try again later.'
            else
              analyze_comments = yt_comments.analyzed
              all_comments = Views::AllComments
                             .new(analyze_comments[:comments], video_id)
              all_comments.classification
              response.expires 60, public: true if App.environment == :produciton
            end
            processing = Views::CommentProcessing.new(
              App.config, yt_comments.response
            )
            view 'comments', locals: { comments: all_comments, 
                                       processing: processing }
          end
        end
      end
    end
  end
end
