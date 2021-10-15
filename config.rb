require 'dotenv/load'
require_relative 'spotify/spotify'

Spotify.config do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
  config.scope = 'playlist-modify-public'
  config.redirect_uri = 'http://example.com'
  config.email = ENV['EMAIL']
  config.password = ENV['PASSWORD']
  config.get_token_base_url = 'https://accounts.spotify.com/api/token'
end
