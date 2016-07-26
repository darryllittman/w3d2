class ModelBase
  def initialize
  end

  def self.find_by_id(id)
    table_name = "#{self.class.downcase}s"

    object = QuestionsDatabase.instance.execute(<<-SQL, id, table_name)
      SELECT
        *
      FROM
        table_name
      WHERE
        table_name.id = ?
    SQL

    return nil unless object.length > 0
    self.new(object.first)
  end
end
