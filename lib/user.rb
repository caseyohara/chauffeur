require 'active_support/all'

class User
  attr_reader :attributes

  def initialize(api, attributes=nil)
    @api = api
    @attributes = attributes || @api.current_user
    @attributes.each do |name, value|
      define_singleton_method name.to_s.underscore, lambda { value }
    end
  end

  def drivers
    @following ||= @api.following(:user => key)
    @drivers ||= @following.map { |attributes| User.new(@api, attributes) }
  end

  def full_name
    [first_name, last_name].join(" ")
  end
end

