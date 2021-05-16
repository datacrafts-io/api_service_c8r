module ApiServiceC8r
  module ServiceMethods
    attr_reader :target_model, :controller, :initial_scope, :current_user,
                :params, :request, :response, :kwargs

    def initialize(target_model:, controller:, initial_scope:, current_user:, **kwargs)
      @target_model  = target_model
      @controller    = controller
      @initial_scope = initial_scope
      @params        = controller.params
      @request       = controller.request
      @response      = controller.response
      @current_user  = current_user
      @kwargs        = kwargs
    end

    def call
      raise NotImplementedError
    end
  end
end
