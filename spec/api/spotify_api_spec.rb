require 'json'
require_relative '../../config'
require_relative '../../models/playlist'

RSpec.describe Spotify do
  context 'with created session' do
    Spotify.create_session

    tracks = %w[spotify:track:2OTsxrA8P5JjBl3kz4478w spotify:track:3Ta3a06kFTBkqADHg4J6KH
                  spotify:track:2bbKaeBn1KrXAPNDpCyHfS spotify:track:1XMVV41wwQPprLCEennJ9i]

    it 'token is not null' do
      expect(Spotify.token.class).to eq String
    end

    it 'creates playlist' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')
      expect(playlist.class).to eq Playlist
      Spotify.unfollow_playlist playlist.id
    end

    it 'empty playlist json is correct' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')
      playlist.owner_name = Spotify.current_user[:display_name]
      empty_playlist = Playlist.new({ name: 'My New Playlist',
                                      description: 'Description for playlist',
                                      owner_name: Spotify.current_user[:display_name],
                                      href: playlist.spotify_url,
                                      id: playlist.id })
      expect(playlist.to_json).to eq empty_playlist.to_json
      Spotify.unfollow_playlist playlist.id
    end

    it 'added 4 tracks' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')



      Spotify.add_tracks_to_playlist(playlist.id, tracks)

      tracks_after = Spotify.playlists_items(playlist.id)

      expect(tracks_after.length).to eq 4

      Spotify.unfollow_playlist playlist.id
    end
  end
end
