require "config"

module ApiServiceC8r
  class Pagination
    attr_reader :scope, :per_page, :page, :config

    def initialize(scope:, per_page:, page:)
      @scope    = scope
      @per_page = per_page
      @page     = page
      @config   = ApiServiceC8r.config
    end

    def call
      send("#{config.pagination}_paginate")
    end

    private

    def kaminari_paginate
      scope.per(per_page).page(page)
    end

    # TODO: add support of another libraries
  end
end
