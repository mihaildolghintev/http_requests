require 'json'

class Track
  class << self
    def from_json(params = {})
      new({
            id: params[:track][:id],
            name: params[:track][:name],
            artist_name: params[:track][:artists].first[:name],
            album_name: params[:track][:album][:name],
            spotify_url: params[:track][:href]
          })
    end
  end
  attr_accessor :id, :name, :artist_name, :album_name, :spotify_url

  def initialize(attrs)
    @id = attrs[:id]
    @name = attrs[:name]
    @artist_name = attrs[:artist_name]
    @album_name = attrs[:album_name]
    @spotify_url = attrs[:spotify_url]
  end

  def to_json(*args)
    {
      id: @id,
      name: @name,
      artist_name: @artist_name,
      album_name: @album_name,
      spotify_url: @spotify_url
    }.to_json(args)
  end
end
