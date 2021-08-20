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