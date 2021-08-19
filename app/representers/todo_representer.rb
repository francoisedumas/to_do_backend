class TodoRepresenter
  def initialize(todo)
    @todo = todo
  end

  def as_json
    {
      id:    todo.id,
      title: todo.title
      # author_name: author_name(todo),
    }
  end

  private

  attr_reader :todo

  # def author_name(todo)
  #   "#{todo.author.first_name} #{todo.author.last_name}"
  # end
end
