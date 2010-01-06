CAMPFIRE_URL = 'https://your-campfire-subdomain.campfirenow.com'
CAMPFIRE_API_TOKEN = 'your campfire api token'
CAMPFIRE_ROOM = "your favourite room" # the NAME of the room, case sensitive
CAMPFIRE_ROOM = "Failroom"

TWITTER_FEED_URL = 'http://search.twitter.com/search.atom?q=YOUR_SEARCH_TERM' # from http://search.twitter.com

CACHE_FILE = 'archived_latest.txt'
OPTIONS = {} # {:twicture => true} # => posts tweets as Twictures

require 'twitter2campfire'

t = Twitter2Campfire.new(TWITTER_FEED_URL, CAMPFIRE_URL, CAMPFIRE_API_TOKEN, CAMPFIRE_ROOM, CACHE_FILE, OPTIONS)
t.publish_entries