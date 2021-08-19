class TodosRepresenter
  def initialize(todos)
    @todos = todos
  end

  def as_json
    todos.map do |todo|
      {
        id:        todo.id,
        title:     todo.title,
        completed: todo.completed
        # author_name: author_name(todo),
      }
    end
  end

  private

  attr_reader :todos

  # def author_name(todo)
  #   "#{todo.author.first_name} #{todo.author.last_name}"
  # end
end
