require 'json'

class Playlist
  attr_accessor :id, :name, :description, :owner_name, :spotify_url, :tracks

  def initialize(params = {})
    @id = params[:id]
    @name = params[:name]
    @description = params[:description]
    @owner_name = params[:owner_name]
    @spotify_url = params[:href]
    @tracks = []
  end

  def to_json(*args)
    {
      id: @id,
      name: @name,
      description: @description,
      owner_name: @owner_name,
      spotify_url: @spotify_url,
      tracks: @tracks
    }.to_json(args)
  end

  def update_tracks(tracks)
    @tracks = tracks
  end
end
