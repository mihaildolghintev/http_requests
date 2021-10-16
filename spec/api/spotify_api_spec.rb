require 'json'
require_relative '../../config'
require_relative '../../models/playlist'
require_relative '../../models/track'

RSpec.describe Spotify do
  context 'with created session' do
    Spotify.create_session
    tracks = %w[spotify:track:2OTsxrA8P5JjBl3kz4478w spotify:track:3Ta3a06kFTBkqADHg4J6KH
                spotify:track:2bbKaeBn1KrXAPNDpCyHfS spotify:track:1XMVV41wwQPprLCEennJ9i]

    track_models = [
      Track.new({
                  id: '2OTsxrA8P5JjBl3kz4478w',
                  name: 'Nemesis',
                  artist_name: 'Benjamin Clementine',
                  album_name: 'At Least For Now',
                  spotify_url: 'https://api.spotify.com/v1/tracks/2OTsxrA8P5JjBl3kz4478w'
                }),
      Track.new({
                  id: '3Ta3a06kFTBkqADHg4J6KH',
                  name: 'Jupiter',
                  artist_name: 'Benjamin Clementine',
                  album_name: 'I Tell A Fly',
                  spotify_url: 'https://api.spotify.com/v1/tracks/3Ta3a06kFTBkqADHg4J6KH'
                }),
      Track.new({
                  id: '2bbKaeBn1KrXAPNDpCyHfS',
                  name: 'Phantom Of Aleppoville',
                  artist_name: 'Benjamin Clementine',
                  album_name: 'Phantom Of Aleppoville',
                  spotify_url: 'https://api.spotify.com/v1/tracks/2bbKaeBn1KrXAPNDpCyHfS'
                }),
      Track.new({
                  id: '1XMVV41wwQPprLCEennJ9i',
                  name: 'Nemesis - Live For Burberry',
                  artist_name: 'Benjamin Clementine',
                  album_name: 'Live For Burberry',
                  spotify_url: 'https://api.spotify.com/v1/tracks/1XMVV41wwQPprLCEennJ9i'
                })
    ]

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
                                      id: playlist.id,
                                      tracks: [] })
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

    it 'track is valid' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')

      Spotify.add_tracks_to_playlist(playlist.id, tracks)

      tracks_after = Spotify.playlists_items(playlist.id)

      expect(tracks_after.first.to_json).to eq track_models.first.to_json

      Spotify.unfollow_playlist playlist.id
    end

    it 'first track should be last' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')

      Spotify.add_tracks_to_playlist(playlist.id, tracks)
      Spotify.reorder_track_position(playlist.id, tracks.first, tracks.length)

      tracks_after = Spotify.playlists_items(playlist.id)

      expect(tracks_after.last.to_json).to eq track_models.first.to_json

      Spotify.unfollow_playlist playlist.id
    end

    it 'should be 3 tracks after remove last' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')

      Spotify.add_tracks_to_playlist(playlist.id, tracks)
      Spotify.reorder_track_position(playlist.id, tracks.first, tracks.length)

      Spotify.remove_track(playlist.id, tracks.first)

      tracks_after = Spotify.playlists_items(playlist.id)

      expect(tracks_after.length).to eq 3

      Spotify.unfollow_playlist playlist.id
    end

    it 'last track should be correct' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')

      Spotify.add_tracks_to_playlist(playlist.id, tracks)
      Spotify.reorder_track_position(playlist.id, tracks.first, tracks.length)

      Spotify.remove_track(playlist.id, tracks.first)

      tracks_after = Spotify.playlists_items(playlist.id)

      expect(tracks_after.last.to_json).to eq track_models.last.to_json

      Spotify.unfollow_playlist playlist.id
    end

    it 'final playlist should be valid' do
      playlist = Spotify.create_playlist('My New Playlist', 'Description for playlist')

      Spotify.add_tracks_to_playlist(playlist.id, tracks)
      Spotify.reorder_track_position(playlist.id, tracks.first, tracks.length)

      Spotify.remove_track(playlist.id, tracks.first)

      playlist_after = Spotify.playlist(playlist.id)
      empty_playlist_model = Playlist.new({ name: 'My New Playlist',
                                            description: 'Description for playlist',
                                            owner_name: Spotify.current_user[:display_name],
                                            href: playlist_after.spotify_url,
                                            id: playlist.id })
      empty_playlist_model.update_tracks(track_models[1..-1])

      expect(playlist_after.to_json).to eq empty_playlist_model.to_json

      Spotify.unfollow_playlist playlist.id
    end
  end
end
