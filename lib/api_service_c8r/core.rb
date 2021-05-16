module ApiServiceC8r
  class Core
    class << self
      def add_config(controller, config_item = {})
        exists_controller_config = config[controller] || {}

        config[controller] = exists_controller_config.merge(**config_item)
      end

      def config
        @config ||= {}
      end
    end
  end
end
