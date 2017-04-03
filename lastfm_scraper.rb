

# The module for last_fm is found at https://github.com/youpy/ruby-lastfm/
require 'lastfm'
require 'json'

api_key = "d704d6b23c79162a62a15cc35abffa82" #GO AHEAD TAKE MY KEYS SEE IF I CARE
api_secret = "ad4d8a61abb15919933326ea20384190"

@lastfm = Lastfm.new(api_key, api_secret)

MAX_CUTTOFF = 12
MATCH_CUTTOFF = 0.07

@ids = []
@songs = []

def id(song)
  id = [song["name"], song["artist"]].join("_")
  id = id.downcase().gsub(/\s+/,"_").gsub(/\W+/,"")

  @ids << id
  id
end


def get_similar(old_song)
  puts old_song
  begin
  results = @lastfm.track.get_similar(old_song["artist"], old_song["name"])
  end
  songs = []

  results.each do |r|
    match = r["match"].to_f
    if match > MATCH_CUTTOFF
      song = {}
      song["match"] = match
      song["name"] = r["name"]
      song["artist"] = r["artist"]["name"]
      song["id"] = id(song)
      song["playcount"] = r["playcount"].to_i
      songs << song
    end
  end
  songs
end

def links_for(origin, songs)
  links = []
  songs.each do |song|
    link = {"source" => origin["id"], "target" => song["id"]}
    reverse_link = {"target" => origin["id"], "source" => song["id"]}
    if !links.include?(link) and !links.include?(reverse_link)
      links << link
    end
  end
  links
end

def unseen_songs(current_songs, new_songs)
  unseen = []
  current_song_ids = current_songs.collect {|cs| cs["id"]}
  new_songs.each do |song|
    if !current_song_ids.include? song["id"]
      unseen << song
    end
  end
  unseen
end

def expand(songs, links, root)
  new_songs = get_similar(root)
  unseen = unseen_songs(songs, new_songs)[0..MAX_CUTTOFF]
  new_links = links_for(root, unseen)
  [unseen, new_links]
end


def grab(root, output_filename)
  links = []
  all_songs = []

  first_iteration, new_links = expand(all_songs, links, root)

  all_songs.concat first_iteration
  links.concat(new_links)

  unlinked_songs = []

  puts all_songs.length
  first_iteration.clone()[1..-1].each do |song|
    puts song["name"]
    new_songs, new_links = expand(all_songs, links, song)
    all_songs.concat(new_songs)
    unlinked_songs.concat(new_songs)
    links.concat(new_links)
    puts all_songs.length
  end


  data = {}
  data["nodes"] = all_songs
  data["links"] = links
  File.open(output_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(data.to_json))
  end
end

roots = [
    #{"name" => "Insight", "artist" => "Haywyre", "filename" => "haywyre.json"},
    #{"name" => "Never Catch Me", "artist" => "Flying Lotus", "filename" => "flying.json" },
  #{"name" => "Backstreet Freestyle", "artist" => "Kendrick Lamar", "filename" => "kendrick.json"},
]

roots.each do |root|
  root["id"]  = id(root)

  grab(root, root["filename"])
end


