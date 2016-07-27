class ModelBase
  def initialize
  end

  def table_string(string)
    table_name = "#{string[0]}"
    if string == string.capitalize
      return "#{string.downcase}s"
    else
      string[1..-1].each_char do |char|
        if char == char.upcase
          table_name << "_#{char}"
        else
          table_name << char
        end
      end
    end

    table_name.downcase + "s"
  end

  def self.find_by_id(id)
    table_name = table_string("#{self.class}")

    object = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    return nil unless object.length > 0
    self.new(object.first)
  end

  def self.all
    table_name = table_string("#{self.class}")
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{table_name}")
    data.map { |datum| self.class.new(datum) }
  end

  def save
    table_name = table_string("#{self.class}")
    vars = instance_variables #[:@name, :@lname, :@id]
    vars.map! { |el| el[1..-1] }

    args = vars.map do |el|
      if self.send(el.to_sym).nil?
        next
      end
      self.send(el.to_sym)
    end



    cols = instance_variables.size
    if @id.nil?
      require 'byebug'; debugger

      QuestionsDatabase.instance.execute(<<-SQL, *args)
        INSERT INTO
          #{table_name} (#{vars[1..-1]})
        VALUES
          (?#{(args.size - 2).times { ', ?'}})
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      #update
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end

    self
  end
end
