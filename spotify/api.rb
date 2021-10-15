require 'watir'
require 'webdrivers'
require 'uri'
require 'cgi'
require 'restclient'
require_relative 'spotify'

require_relative '../models/playlist'

module Spotify
  module API
    class Auth
      class << self
        def generate_auth_code
          browser = Watir::Browser.new :chrome
          browser.goto generate_url
          email_field = browser.text_field(id: 'login-username')
          email_field.set(Spotify.email)

          password_field = browser.text_field(id: 'login-password')
          password_field.set(Spotify.password)

          browser.button(id: 'login-button').click

          Watir::Wait.until { browser.url.start_with?(Spotify.redirect_uri) }

          CGI.parse(URI.parse(browser.url).query)['code'].first
        end

        def get_token(auth_code)
          payload = {
            grant_type: 'authorization_code',
            code: auth_code,
            redirect_uri: Spotify.redirect_uri,
            client_id: Spotify.client_id,
            client_secret: Spotify.client_secret
          }
          res = RestClient::Request.execute(method: :post, url: Spotify.get_token_base_url, payload: payload,
                                            headers: { content_type: 'application/x-www-form-urlencoded', accept: 'application/json' })
          JSON.parse(res.body)['access_token']
        end

        private

        def generate_url
          %W[
            https://accounts.spotify.com/authorize
            ?response_type=code
            &client_id=
            #{Spotify.client_id}
            &scope=
            #{Spotify.scope}
            &redirect_uri=
            #{Spotify.redirect_uri}
          ].join('')
        end
      end
    end

    class Profile
      class << self
        def get_profile(token)
          url = 'https://api.spotify.com/v1/me'
          res = RestClient.get(url, { Authorization: "Bearer #{token}" })
          JSON.parse(res.body, symbolize_names: true)
        end
      end
    end

    class Playlists
      class << self
        def create(token, user_id, payload)
          url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
          res = RestClient::Request.execute(method: :post,
                                            url: url,
                                            payload: payload.to_json,
                                            headers: { Authorization: "Bearer #{token}" })
          JSON.parse(res.body, symbolize_names: true)
        end

        def all(token)
          url = 'https://api.spotify.com/v1/me/playlists'
          res = RestClient.get(url, { Authorization: "Bearer #{token}" })

          JSON.parse(res.body, symbolize_names: true)[:items]
        end

        def playlist(token, playlist_id)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}"
          res = RestClient.get(url, { Authorization: "Bearer #{token}",
                                      params: { fields: 'id,name,description,href' } })

          JSON.parse(res.body, symbolize_names: true)
        end

        def playlist_items(token, playlist_id)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
          res = RestClient::Request
                .execute(method: :get,
                         url: url,
                         headers: { Authorization: "Bearer #{token}",
                                    params: { fields: 'items(track(id,name,href,album(name),artists(name)))' } })
          JSON.parse(res.body, symbolize_names: true)
        end

        def add_tracks(token, playlist_id, tracks_urls)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
          res = RestClient::Request.execute(method: :post,
                                            url: url,
                                            payload: { uris: tracks_urls, position: 0 }.to_json,
                                            headers: { Authorization: "Bearer #{token}",
                                                       'Content-Type': 'application/json' })
          JSON.parse(res.body, symbolize_names: true)
        end

        def change_track_position(token, playlist_id, track_url, position)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
          res = RestClient::Request.execute(method: :put,
                                            url: url,
                                            uris: track_url,
                                            payload: { range_start: 0, insert_before: position }.to_json,
                                            headers: { Authorization: "Bearer #{token}" })
          JSON.parse(res.body, symbolize_names: true)
        end

        def remove_track(token, playlist_id, track_url)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
          res = RestClient::Request.execute(method: :delete,
                                            url: url,
                                            payload: { tracks: [{ uri: track_url }] }.to_json,
                                            headers: { Authorization: "Bearer #{token}",
                                                       'Content-Type': 'application/json' })
          JSON.parse(res.body, symbolize_names: true)
        end

        def unfollow_playlist(token, playlist_id)
          url = "https://api.spotify.com/v1/playlists/#{playlist_id}/followers"
          RestClient::Request.execute(method: :delete,
                                      url: url,
                                      playlist_id: playlist_id,
                                      headers: { Authorization: "Bearer #{token}" })
        end
      end
    end
  end
end
