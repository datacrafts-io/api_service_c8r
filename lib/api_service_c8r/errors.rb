module ApiServiceC8r
  class BaseError < StandardError
    attr_reader :message
  end

  class ForbiddenActionName < BaseError
    def initialize(action_name, controller)
      @message = "Forbidden action name :#{action_name} in #{controller}"
      super(@message)
    end
  end

  class ServiceNotFound < BaseError
    def initialize(service_namespace)
      @message = "Service #{service_namespace} is not found"
      super(@message)
    end
  end

  class NoPaginationData < BaseError
    def initialize(params)
      @message = <<~TEXT
        Expected "pagination" => { "per_page" => int, "page" => int } hash in params.
        No pagination data in: #{params}
      TEXT
      super(@message)
    end
  end
end
