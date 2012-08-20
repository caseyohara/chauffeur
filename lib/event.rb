require 'initializable_from_api_hash'

class Event
  include InitializableFromApiHash
  skip_hash_items 'track'

  def date
    Time.parse(self.time).to_datetime.strftime("%A, %B %d at %I:%M%P")
  end

  def track
    Track.new(api, attributes['track'])
  end
end


