require "config"

module ApiServiceC8r
  class Serializer
    attr_reader :serializer, :config, :scope

    def initialize(serializer:, scope:)
      @serializer = serializer
      @scope      = scope
      @config     = ApiServiceC8r.config
    end

    def call
      send("#{config.serializer}_serialize")
    end

    private

    def blueprinter_serialize
      serializer.render_as_json(scope)
    end

    # TODO: add support of another libraries
  end
end
