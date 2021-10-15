require_relative 'config'

Spotify.create_session

playlist = Spotify.create_playlist('My new playlist', 'Comment For Playlist')

tracks = %w[spotify:track:2OTsxrA8P5JjBl3kz4478w spotify:track:3Ta3a06kFTBkqADHg4J6KH
            spotify:track:2bbKaeBn1KrXAPNDpCyHfS spotify:track:1XMVV41wwQPprLCEennJ9i]

Spotify.add_tracks_to_playlist(playlist.id, tracks)
items = Spotify.playlists_items(playlist.id)

Spotify.reorder_track_position(playlist.id, items.first.id, items.count)

Spotify.remove_track(playlist.id, "spotify:track:#{items.first.id}")
playlist = Spotify.playlist(playlist.id)
puts playlist.to_json
Manager.unfollow_playlist(playlist.id)
