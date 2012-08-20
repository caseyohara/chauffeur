require "initializable_from_api_hash"

class User
  include InitializableFromApiHash
  default_api_method :current_user

  def drivers
    @following ||= @api.following(:user => key)
    @drivers ||= @following.map { |attributes| User.new(@api, attributes) }
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
      "Unknown"
    end
  end
end

