module ApiServiceC8r
  module Constants
    # serializers
    DEFAULT_SERIALIZER = :blueprinter

    # paginations
    DEFAULT_PAGINATION = :kaminari

    ALLOWED_ACTIONS = %i[index show new create edit update destroy].freeze
  end
end
