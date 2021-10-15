require_relative 'spotify/spotify'

Spotify.config do |config|
  config.client_id = '242f1510a4244b92853e89bbdff00560'
  config.client_secret = '8641bb5a1da043c6ac86eb5dec86132b'
  config.scope = 'playlist-modify-public'
  config.redirect_uri = 'http://example.com'
  config.email = 'yadolghintev@gmail.com'
  config.password = 'Dolghintev1'
  config.get_token_base_url = 'https://accounts.spotify.com/api/token'
end
