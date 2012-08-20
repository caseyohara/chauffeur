require "initializable_from_api_hash"
require 'track'
require 'event'

NullObject = Object.new

class << NullObject
  def method_missing(sym, *args)
    self
  end

  def to_s
    "Unknown"
  end
end

class User
  include InitializableFromApiHash
  default_api_method :current_user

  def drivers
    @following ||= @api.following(:user => key)
    @following.map { |attributes| User.new(@api, attributes) }
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def nickname
    url.split('/').last
  end

  def last_seen
    if last_song_play_time.present?
      Time.parse(last_song_play_time).to_datetime.strftime("%A, %B %d at %I:%M%P")
    else
      NullObject
    end
  end

  def last_track
    if last_song_played.present?
      Track.new(@api, last_song_played)
    else
      NullObject
    end
  end

  def events
    @events ||= @api.events(:user => key)
    @events.map do |event|
      event['tracks'].map do |playback_event|
        Event.new(@api, playback_event)
      end
    end.flatten
  end

end

