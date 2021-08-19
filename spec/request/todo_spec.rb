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
      expect(response_body.size).to eq(2)
      expect(response_body).to eq(
        # there is a reverse in the controller so the id 2 come before id 1
        [
          {
            'id'        => 2,
            'title'     => 'My second task',
            'completed' => false
          },
          {
            'id'        => 1,
            'title'     => 'My first task',
            'completed' => false
          }
        ]
      )
    end
  end

  describe 'POST /todos' do
    it 'create a new todo' do
      expect { # rubocop:disable Style/BlockDelimiters
        post '/api/v1/todos', params: {
          todo: {
            title: 'Read the Martian'
          }
        }
      }.to change { Todo.count }.from(0).to(1)

      expect(response).to have_http_status(:created)
      expect(response_body).to eq(
        # db cleaner doesn't work should be id 1
        {
          'id'    => 3,
          'title' => 'Read the Martian'
        }
      )
    end
  end

  describe 'DELETE /todos/:id' do
    let!(:todo) { FactoryBot.create(:todo, title: 'My delete test') }

    it 'deletes a todo' do
      expect { delete "/api/v1/todos/#{todo.id}" }.to change { Todo.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end
  end
end
