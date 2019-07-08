#
#   Defines `#nested_resource` and `#nested_resources` routing methods -
# available in routes.rb - allowing us to follow the URL context principle in
# an easier way.
#
#   Example:
#
#     Suppose we have a Person, which has many Ideas.
#     An Idea cannot exist without a Person. Therefore, we want to define
#   Person (owner) as a context for the Idea (owned).
#
#     Thinking about RESTful URLs, we come up with:
#
#   ```
#   /people/:person_id/ideas/:id
#   ```
#
#     How would we accomplish it with pure Rails routing?:
#
#   ```ruby
#   # routes.rb
#   Rails.application.routes.draw do
#     # ...
#
#     resources :people do
#       resources :ideas
#     end
#   end
#   ```
#
#     But then, when we look at our `app/controllers` directory, we see
#   - `app/controllers/people_controller`
#   - `app/controllers/ideas_controller`
#
#     What if we could make them follow the same URL "context"?
#   - `app/controllers/people_controller`
#   - `app/controllers/people/ideas_controller`
#
#     We can do it with pure Rails routing:
#   ```ruby
#   # routes.rb
#   Rails.application.routes.draw do
#     # ...
#
#     resources :people do
#       resources :ideas, module: :people
#     end
#   end
#   ```
#
#     But what if Person is the "context" for many resources? Replicating this
#   `module: :people` will uglify our `routes.rb`.
#   ```ruby
#   # routes.rb
#   Rails.application.routes.draw do
#     # ...
#
#     resources :people do
#       resources :ideas, module: :people
#       resources :inventions, module: :people
#       resource :profile, module: :people
#     end
#   end
#   ```
#
#
#     Here's how we would do it with the handy `#nested_resource` and
#   `#nested_resources` route helper methods:
#   ```ruby
#   # routes.rb
#   Rails.application.routes.draw do
#     # ...
#
#     resources :people do
#       nested_resources :ideas
#       nested_resources :inventions
#       nested_resource :profile
#     end
#   end
#   ```
#
module ActionDispatch
  module Routing
    class Mapper
      module Resources

        def nested_resource(*resources, &block)
          options = resources.extract_options!
            .merge(module: parent_resource.plural)

          resource(*resources, options, &block)
        end


        def nested_resources(*resources, &block)
          options = resources.extract_options!
            .merge(module: parent_resource.plural)

          resources(*resources, options, &block)
        end
      end
    end
  end
end
