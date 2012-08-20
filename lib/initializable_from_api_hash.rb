require 'active_support/all'

module InitializableFromApiHash
  attr_reader :api, :attributes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :defined_default_api_method

    def default_api_method(method)
      @defined_default_api_method = method
    end
  end

  def initialize(api, attributes=nil)
    @api = api
    @attributes = attributes || @api.send(self.class.defined_default_api_method)
    @attributes.each do |name, value|
      define_singleton_method name.to_s.underscore, lambda { value }
    end
  end
end

