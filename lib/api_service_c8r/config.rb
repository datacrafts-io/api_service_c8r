require "constants"

module ApiServiceC8r
  def self.configure
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    include ApiServiceC8r::Constants

    attr_accessor :serializer, :pagination

    def initialize
      @serializer = DEFAULT_SERIALIZER
      @pagination = DEFAULT_PAGINATION
    end
  end
end
