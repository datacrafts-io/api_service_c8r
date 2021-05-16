require "core"

module ApiServiceC8r
  class GenerateActionData
    attr_reader :config, :target_model, :serializer, :use_policy_scope,
                :use_pagination, :service_namespace, :service

    def initialize(controller, action_name)
      config = ApiServiceC8r::Core.config[controller]

      extract_config_data!(config, action_name)
      extract_service_data!(controller, action_name)
    end

    private

    def extract_config_data!(config, action_name)
      @target_model     = config[:target_model]
      @serializer       = config.dig(:serializer_config, action_name)
      @authorize_user   = config.dig(:policy_config, :authorize).include?(action_name)
      @use_policy_scope = config.dig(:policy_config, :policy_scope).include?(action_name)
      @use_pagination   = config.fetch(:pagination_config, []).include?(action_name)
    end

    def extract_service_data!(controller, action_name)
      @service_namespace = "#{controller.name.gsub('Controller', '')}::#{action_name.capitalize}"
      @service           = service_namespace.safe_constantize
    end
  end
end
