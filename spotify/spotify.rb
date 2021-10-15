require_relative 'api'
require_relative '../models/track'

module Spotify
  class << self
    attr_accessor :playlists, :tracks, :code, :token, :current_user,
                  :client_id, :client_secret, :scope, :redirect_uri,
                  :email, :password, :get_token_base_url

    def config
      yield self
    end

    def create_session
      @code = Spotify::API::Auth.generate_auth_code
      @token = Spotify::API::Auth.get_token code
      @current_user = Spotify::API::Profile.get_profile @token
    end

    # def all_playlists
    #   res = []
    #   playlists = Spotify::Playlists.all(@token)
    #   playlists.each do |list|
    #     tracks = playlists_items(list[:id])
    #     pl = Playlist.new(list.merge({ owner_name: @current_user[:display_name] }))
    #     pl.update_tracks(tracks)
    #     res << pl.to_json
    #   end
    #   res
    # end

    def playlist(playlist_id)
      list = Spotify::API::Playlists.playlist(@token, playlist_id)
      tracks = playlists_items(playlist_id)
      pl = Playlist.new(list.merge({ owner_name: @current_user[:display_name] }))
      pl.update_tracks(tracks)
      pl
    end

    def create_playlist(name, description)
      playlist = Spotify::API::Playlists.create(@token, @current_user[:id], { name: name,
                                                                              description: description })
      Playlist.new playlist
    end

    def playlists_items(playlist_id)
      items = Spotify::API::Playlists.playlist_items(@token, playlist_id)

      items[:items].map { |item| Track.new item }
    end

    def add_tracks_to_playlist(playlist_id, track_urls)
      Spotify::API::Playlists.add_tracks(@token, playlist_id, track_urls)
    end

    def reorder_track_position(playlist_id, track_url, position)
      Spotify::API::Playlists.change_track_position(@token, playlist_id, track_url, position)
    end

    def remove_track(playlist_id, track_url)
      Spotify::API::Playlists.remove_track(@token, playlist_id, track_url)
    end

    def unfollow_playlist(playlist_id)
      Spotify::API::Playlists.unfollow_playlist(@token, playlist_id)
    end
  end
end
