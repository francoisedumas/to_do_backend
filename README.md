# RoR API
## Introduction to API using Ruby on Rails

This API exercise is based on the video https://youtu.be/6KqbPJtA5O8
The target is to build a simple todo application using
 - RoR as an API back end
 - VueJS for the front end

<img width="1149" alt="Screenshot 2021-08-13 at 16 55 19" src="https://user-images.githubusercontent.com/33062224/129376658-9000b534-5c34-466c-b108-134a755e1cc8.png">

## Setup for fork and clone

The front-end can be found [here](https://github.com/francoisedumas/to_do_frontend)

After cloning or forking run `rails db:create` `rails db:migrate` and `rails s` in your terminal to start the app. If you want to run the test rub rspec. Enjoy! 😀

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
  params.require(:todo).permit(:id, :title, :completed)
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

## Deploying with Heroku

### Solving issue with Gemfile.lock
I had issues with the Gemfile.lock and with the next error
```
Your bundle only supports platforms ["x86_64-darwin-19"] but your local
platform is x86_64-linux. Add the current platform to the lockfile with
`bundle lock --add-platform x86_64-linux` and try again.
```

It's been solved with `bundle lock --add-platform x86_64-linux` and `bundle lock --add-platform ruby`
[A good article about it here](https://www.moncefbelyamani.com/understanding-the-gemfile-lock-file/)

### Solving issue with Sqlite3

If using Sqlite3 you have the next error with Heroku `Detected sqlite3 gem which is not supported on Heroku:` To solve it follow the [article here](https://devcenter.heroku.com/articles/sqlite3)

### Deploy & migrate

Now run `git push heroku master ` and `heroku run rails db:migrate` then go to the URL of your app followed by `api/v1/todos` for me its `https://todobackendror.herokuapp.com/api/v1/todos`

## Clean code with Rubocop
Go to your Gemfil and add below gem
```ruby
group :development do
  #...
  gem 'rubocop', '~> 1.14', require: false
end
```

Create a `.rubocop.yml` and copy paste the code from this app file (too long to paste here)

## Adding tests 😇

### Rspec setup
Go to your Gemfil and add below gem
```ruby
group :development, :test do
  #...
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :test do
  gem 'database_cleaner'
end
```
In the terminal
```
bundle
rails generate rspec:install
```

```ruby
# in the rails_helper.rb uncomment below line
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
# turn below line to false
config.use_transactional_fixtures = false
```

#### DB cleaner
Create a spec/support folder and add a database_cleaner_spec.rb file
```ruby
RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }	
  config.before(:each) { DatabaseCleaner.strategy = :transaction }	
  config.before(:each, js: true) { DatabaseCleaner.strategy = :truncation }	
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
end
```
#### Creating factorie
Create a spec/factories folder and add a todo.rb file
```ruby
FactoryBot.define do
  factory :todo do
  end
end
```

## The tests 

### Request tests
Create a spec/requests folder and add a todo_spec.rb file
```ruby
require 'rails_helper'

describe 'Todos API', type: :request do
    
  describe 'GET /todos' do
    before do
      FactoryBot.create(:todo, title: 'My first task', completed: false)
      FactoryBot.create(:todo, title: 'My second task', completed: false)
    end

    it 'returns all todos' do
      get '/api/v1/todos'

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
      expect(JSON.parse(response.body)).to eq(
        # there is a reverse in the controller so the id 2 come before id 1
        [
          {
            'id' => 2,
            'title' => 'My second task',
            'completed' => false
          },
          {
          'id' => 1,
          'title' => 'My first task',
          'completed' => false
          }
        ]
      )
    end
  end

  describe 'POST /todos' do
    it 'create a new todo' do
      expect {
        post '/api/v1/todos', params: {
          todo: { title: 'Read the Martian' }
        }
      }.to change { Todo.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq(
        # db cleaner doesn't work should be id 1
        {
          'id' => 3,
          'title' => 'Read the Martian'
        }
      )
    end
  end

  describe 'DELETE /todos/:id' do
    let!(:todo) { FactoryBot.create(:todo, title: 'My delete test') }

    it 'deletes a todo' do
      expect {
        delete "/api/v1/todos/#{todo.id}"
      }.to change { Todo.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end
  end
end
```

#### Drying test
Testing API we often use `JSON.parse(response.body)` to dry it up create a request_helper.rb file in spec folder
```ruby
module RequestHelper
  def response_body
    JSON.parse(response.body)
  end
end
```
In the spec_helper.rb file
```ruby
require 'request_helper'
# ...
# at the bottom in the config area before the last end add
config.include RequestHelper, type: :request
```
Now in every Rspec file with `type: :request` you can replace `JSON.parse(response.body)` by `response_body` and you don't need to use `require 'request_helper'` at the top of the file

#### Controller test
Create a spec/controllers folder and add a todos_controller_spec.rb file
```ruby
require 'rails_helper'

RSpec.describe Api::V1::TodosController, type: :controller do
  it 'has a max limit of 100' do
    # explanation https://youtu.be/SQhj5gBNTB0 about 7:40
    expect(Todo).to receive(:limit).with(100).and_call_original

    get :index, params: { limit: 999 }
  end
end
```

#### Model test
Create a spec/models folder and add a todo_spec.rb file
```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  subject(:my_todo) { Todo.create(title: "That's a todo", completed: false) }

  it 'is created' do
    expect(my_todo).to be_valid
  end

  it 'can be checked for object attribute and proper values' do
    expect(my_todo).to have_attributes(title: "That's a todo", completed: false)
  end
end
```
