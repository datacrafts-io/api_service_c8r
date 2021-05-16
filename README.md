# ApiServiceC8r
Move you actions logic to services and keep controllers clean

## Installation:
Add to your Gemfile:
```ruby
gem "api_service_c8r", github: "datacrafts-io/api_service_c8r"
```

## Usage:
Include `ApiServiceC8r::Base` module to `application_controller.rb`
```ruby
class ApplicationController < ActionController::API
  include ApiServiceC8r::Base

  def current_user; end
end

```

Create you `posts_controller.rb`
```ruby
class Api::V1::PostsController < ApplicationController
  target_model Post

  use_policy on: %i[show create destroy], policy_scope: %i[show destroy]
  use_pagination on: %i[show]
  use_serializer PostsSerializer, on: %i[show]

  action :show
  action :create, render_result: false, without_initial_scope: true
  action :destroy, render_result: false
end
```

### Serializer
By default using `Blueprinter` serializer
```ruby
class PostsSerializer < Blueprinter::Base
  identifier :id

  fields :title, :body
end

```

### Policy
By default using `Pundit` policy
```ruby
class PostPolicy < ApplicationPolicy
  def show?
    true
  end

  alias create? show?
  alias destroy? show?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      user.posts
    end
  end
end

```
### Pagination
By default using `Kaminari` pagination

### Next
After that you need to create services for each action and implement `call` method in them:
* For `show` action in `services/api/v1/posts/show.rb`
```ruby
class Api::V1::Posts::Show < ControllerService
  def call
    scope = add_joins(initial_scope)
    scope = add_filter(scope)
    add_order(scope)
  end

  private

  def add_joins(scope)
    scope.joins(:author)
  end

  def add_filter(scope)
    scope.where(author: { city: params[:author_city] })
  end

  def add_order(scope)
    scope.order(created_at: :desc)
  end
end
```

* For `create` action in `services/api/v1/posts/create.rb`
```ruby
class Api::V1::Posts::Create < ControllerService
  def call
    target_model.create!(post_params)

    # some another logic
  end

  private

  def post_params
    @post_params ||= params.require(:post).permit(:title, :body)
  end
end
```

* For `destroy` action in `services/api/v1/posts/destroy.rb`
```ruby
class Api::V1::Posts::Destroy < ControllerService
  def call
    post.destroy!

    # some another logic
  end

  private

  def post
    @post ||= initial_scope.find(params[:id])
  end
end
```

You need to include `ApiServiceC8r::ServiceMethods` to your services.
For convenience you can create some parent service and inherit your actions services from it.
For example `services/api/v1/controller_service.rb`
```ruby
class Api::V1::ControllerService
  include ApiServiceC8r::ServiceMethods
end
```

### By default you have the next readers in service:
* `target_model`  - your target model
* `controller`    - controller instance
* `initial_scope` - scope of data which 
* `params`        - params which you passed with request
* `request`       - request instance
* `response`      - response instance
* `current_user`  - current user
* `kwargs`        - another arguments passed with `action` method

## Configuration:
You can use another pagination library or serialize library
Create `config/initializers/api_service_c8r.rb`
```ruby
ApiServiceC8r.configure do |config|
  config.serializer = :another_serializer_library
  config.pagination = :another_pagination_library
end

```
