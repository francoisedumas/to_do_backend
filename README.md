# RoR API
## Introduction to API using Ruby on Rails

This API exercise is based on the video series https://youtu.be/gnymlh4Ljvw
The target is to build a simple todo store application using
 - RoR as an API back end
 - VueJS for the front end

<img width="1272" alt="Screenshot 2021-07-02 at 16 19 25" src="https://user-images.githubusercontent.com/33062224/124288579-9f841700-db51-11eb-9746-d943bf014b38.png">

## Starting with basic models and controllers

### Rails new

Let's start by creating a new Rails app with only api features
In the terminal
```
rails new to_do_backend --api

cd to_do_backend
git add . && git commit -m "To Do api rails new app"
gh repo create
git push origin master
```

### Scaffold the To Do!

`rails g scaffold todos title completed:boolean`
`rails db:migrate`

Let's get some seeds
`Todo.create!(title: 'Hello, world', completed: true)`
`Todo.create!(title: 'Learn RoR API', completed: false)`
`Todo.create!(title: 'Learn front with VueJS', completed: false)`

### Cors gem

Uncomment the `gem 'rack-cors'` and bundle
Got to the folder config/initializers/cors.rb and uncomment the code and change the `origins 'example.com'` with `'http://localhost:8080'`

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8080'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

### API: routes & controllers

Now we will create the structure of our app for the API.
Go to the file routes.rb and create the below routes
```ruby
namespace :api do
  namespace :v1 do
    resources :todos
  end
end
```
build the next folder structure in your app/controllers folder
```
/controllers
    /api
        /v1
```
In this folder move the todos_controller.rb
Updade the class by adding Api::V1 `class Api::V1::TodosController < ApplicationController`

### Updating the controller with limits

Let's modify the todos_controller.rb as below
```ruby
#...
def index
  @todos = Todo.limit(limit).offset(params[:offset])

  render json: @todos.reverse
end
# in private
def todo_params
  params.require(:todo).permit(:id, :title, :completed, :_limit)
end

def limit
  [
    params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
    MAX_PAGINATION_LIMIT
  ].min
end
```

### Representer

So far we push everything in our API let's shape it as we want it to be
Add a representers folder in your app/ folder
```
/app
    /representers
      todos_representer.rb
      todo_representer.rb
```
Add the below code for the todos
```ruby
class TodosRepresenter
  def initialize(todos)
    @todos = todos
  end

  def as_json
    todos.map do |todo|
      {
        id: todo.id,
        title: todo.title
      }
    end
  end

  private

  attr_reader :todos
end
```

And below code for todo
```ruby
class TodoRepresenter
  def initialize(todo)
    @todo = todo
  end

  def as_json
    {
      id: todo.id,
      title: todo.title
    }
  end

  private

  attr_reader :todo
end
```

In the todos controller replace as below
```ruby
# before
def index
  render json: Todo.all
end

#after
def index
  todos = Todo.all

  render json: TodosRepresenter.new(todos).as_json
end

# in the create function do the same update
if todo.save
  render json: TodoRepresenter.new(todo).as_json, status: :created
else
```
