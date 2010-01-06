require 'rubygems'
require 'rio'
require 'hpricot'
require 'ostruct'
require 'time'
require 'htmlentities'
require 'digest/sha1'
require "campfire"

class Twitter2Campfire
  attr_accessor :feed, :campfire, :room, :cachefile, :options
  
  def initialize(feed, campfire_url, campfire_api_token, campfire_room, cachefile = 'archived_latest.txt', options = {})
    Campfire.base_uri campfire_url
    Campfire.basic_auth campfire_api_token, 'x'
    campfire_room_id = Campfire.rooms.find {|room| room['name'] === campfire_room}["id"]
    
    self.room = Campfire.room(campfire_room_id)
    self.feed = feed
    self.cachefile = cachefile
    self.options = options
  end
  
  def raw_feed
    @doc ||= Hpricot(rio(feed) > (string ||= ""))
  end
  
  def entries
    (raw_feed/'entry').map do |e|
      OpenStruct.new(
        :from => (e/'name').inner_html,
        :text => (e/'title').inner_html,
        :link => (e/'link[@rel=alternate]').first['href'],
        :checksum => Digest::SHA1.hexdigest((e/'title').inner_html),
        :date => Time.parse((e/'updated').inner_html),
        :twicture => "http://twictur.es/i/#{(e/'id').inner_html.split(':').last}.gif"
        )
    end
  end
  
  def latest_tweet
    entries.first
  end
  
  def save_latest(last_checksum_index = -1)
    f = File.exist?(cachefile)? File.open(cachefile, 'a') : File.new(cachefile, 'w')
    f.write("\n#{new_archive_contents(last_checksum_index)}")
  end
  
  def checksums
    entries.map { |e| e.checksum }.to_a
  end
  
  def archived_checksums
    archive_file.split("\n")
  end
  
  def new_checksums
    checksums.flatten.uniq[0,1000]
  end
  
  def archive_file
    begin
      return File.read(cachefile)
    #rescue
    #  ''
    end
  end
  
  def new_archive_contents(last_checksum_index = -1)
    "#{new_checksums[0..(new_checksums.size - last_checksum_index + 1)].join("\n")}"
  end
  
  def posts
    entries.reject { |e| archived_checksums.include?(e.checksum) }
  end
  
  def coder
    HTMLEntities.new
  end
  
  def publish_entries
    posts.reverse.each_with_index do |post, index|
      begin
        if options[:twicture]
          room.message post.twicture
        else
          room.message "#{coder.decode(post.from)}: #{coder.decode(post.text)} #{post.link}"
        end
      rescue Timeout::Error
        save_latest(posts.size - index)
        exit(1)
      end
    end
    save_latest
  end
  
end
