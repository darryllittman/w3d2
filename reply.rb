require_relative 'questions_database'
class Reply
  attr_accessor :question_id, :user_id, :parent_reply_id, :body

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map { |datum| Reply.new(datum) }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_reply_id, @body)
        INSERT INTO
          replies (question_id, user_id, parent_reply_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      #update
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_reply_id, @body, @id)
        UPDATE
          replies
        SET
          question_id = ?, user_id = ?, parent_reply_id = ?, body = ?
        WHERE
          id = ?
      SQL
    end

    self
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    self.find_by_id(@parent_reply_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_reply_id = ?
      SQL

    replies.map { |datum| Reply.new(datum) }
  end
end
