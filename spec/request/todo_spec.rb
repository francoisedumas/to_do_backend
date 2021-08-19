require 'rails_helper'

describe 'Todos API', type: :request do
    
  describe 'GET /books' do
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

#   describe 'POST /books' do
#     it 'create a new book' do
#       expect {
#         post '/api/v1/books', params: {
#           book: { title: 'The Martian' },
#           author: { first_name: 'Andy', last_name: 'Weir', age: '48'}
#         }
#       }.to change { Book.count }.from(0).to(1)

#       expect(response).to have_http_status(:created)
#       expect(Author.count).to eq(1)
#       expect(JSON.parse(response.body)).to eq(
#         {
#           'id' => 1,
#           'title' => 'The Martian',
#           'author_name' => 'Andy Weir',
#           'author_age' => 48
#         }
#       )
#     end
#   end

#   describe 'DELETE /books/:id' do
#     let!(:book) { FactoryBot.create(:book, title: '1984', author: first_author) }

#     it 'deletes a book' do
#       expect {
#         delete "/api/v1/books/#{book.id}"
#       }.to change { Book.count }.from(1).to(0)

#       expect(response).to have_http_status(:no_content)
#     end
#   end
end