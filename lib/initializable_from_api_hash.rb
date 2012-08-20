require 'active_support/all'

module InitializableFromApiHash
  attr_reader :api, :attributes

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_accessor :defined_default_api_method
    attr_accessor :defined_skip_hash_items

    def default_api_method(method)
      @defined_default_api_method = method
    end

    def skip_hash_items(*args)
      @defined_skip_hash_items = args
    end

    def defined_skip_hash_items
      @defined_skip_hash_items || []
    end
  end

  def initialize(api, attributes=nil)
    @api = api
    @attributes = attributes || @api.send(self.class.defined_default_api_method)
    @attributes.each do |name, value|
      next if self.class.defined_skip_hash_items.include?(name)
      define_singleton_method name.to_s.underscore, lambda { value }
    end
  end
end

