require "core"
require "errors"
require "constants"
require "serializer"
require "pagination"
require "pundit"
require "generate_action_data"

module ApiServiceC8r
  module Base
    module ClassMethods
      include ApiServiceC8r::Constants

      def target_model(model)
        ApiServiceC8r::Core.add_config(self, target_model: model)
      end

      def use_policy(on: [], policy_scope: [])
        policy_config = {
          authorize: on.is_a?(Array) ? on : [],
          policy_scope: policy_scope.is_a?(Array) ? policy_scope : []
        }

        ApiServiceC8r::Core.add_config(self, policy_config: policy_config)
      end

      def use_serializer(serializer_class, on: [])
        ApiServiceC8r::Core.add_config(self, serializer_config: build_cofig(serializer_class, on))
      end

      def use_pagination(on: [])
        pagination_config = on.is_a?(Array) ? on : []

        ApiServiceC8r::Core.add_config(self, pagination_config: pagination_config)
      end

      def action(name, kwargs = {})
        action_name = name.to_sym

        raise ApiServiceC8r::ForbiddenActionName.new(action_name, self) unless ALLOWED_ACTIONS.include?(action_name)

        generate_method(action_name, kwargs)
      end

      private

      def build_cofig(klass, actions)
        actions.each_with_object({}) do |action, config|
          action_name = action.to_sym
          next unless ALLOWED_ACTIONS.include?(action_name)

          config[action_name] = klass
        end
      end

      def generate_method(action_name, render_result: true, status: :ok, **kwargs)
        config                = ApiServiceC8r::GenerateActionData.new(self, action_name)
        without_initial_scope = kwargs.fetch(:without_initial_scope, false)

        define_method(action_name) do
          authorize config.target_model if config.authorize_user
          raise ApiServiceC8r::ServiceNotFound, config.service_namespace if config.service.blank?

          service_result    = get_service_result(config, without_initial_scope, kwargs)
          pagination_result = get_paginated(service_result, config.use_pagination)

          render_data(render_result, pagination_result, config.serializer, status)
        end
      end
    end

    module InstanceMethods
      private

      def get_service_result(config, without_initial_scope, kwargs)
        config.service.new(
          controller: self,
          target_model: config.target_model,
          initial_scope: initial_scope(config.use_policy_scope, without_initial_scope, config.target_model),
          current_user: current_user,
          **kwargs
        ).call
      end

      def get_serialized_data(scope, serializer)
        ApiServiceC8r::Serializer.new(scope: scope, serializer: serializer).call
      end

      def get_paginated(scope, use_pagination)
        if use_pagination
          per_page = params.dig(:pagination, :per_page)
          page     = params.dig(:pagination, :page)

          validate_pagination_params(per_page, page)
          ApiServiceC8r::Pagination.new(scope: scope, per_page: per_page, page: page).call
        else
          scope
        end
      end

      def validate_pagination_params(per_page, page)
        raise ApiServiceC8r::NoPaginationData, params if per_page.blank? || page.blank?
      end

      def initial_scope(use_policy_scope, without_initial_scope, target_model)
        return if without_initial_scope

        if use_policy_scope
          policy_scope target_model
        else
          target_model.all
        end
      end

      def render_data(render_result, pagination_result, serializer, status)
        if render_result
          serialized_data = get_serialized_data(pagination_result, serializer)

          render json: {
            data: serialized_data
          }, status: status
        else
          head :ok
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end
  end
end
