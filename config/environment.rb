# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'delegate' # This line is needed for Flash due to a bug in Rack < 2.3.0

module GetComment
  # Configuration for the App
  class App < Roda
    # this plugin provides methods including environment, development?, test?, production?, configure
    plugin :environments

    # econfig checks three places for environment variables, order: ENV, secrets.yml, app.yml
    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    # Set up sessions
    use Rack::Session::Cookie, secret: config.SESSION_SECRET
  end
end
