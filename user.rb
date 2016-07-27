require_relative 'questions_database'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    return nil unless user.length > 0
    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    return nil unless user.length > 0
    User.new(user.first)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def average_karma
    QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT questions.id)
      FROM
        questions
        LEFT OUTER JOIN question_likes
        ON questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    SQL
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  # def save
  #   if @id.nil?
  #     QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
  #       INSERT INTO
  #         users (fname, lname)
  #       VALUES
  #         (?, ?)
  #     SQL
  #     @id = QuestionsDatabase.instance.last_insert_row_id
  #   else
  #     #update
  #     QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
  #       UPDATE
  #         users
  #       SET
  #         fname = ?, lname = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   end
  #
  #   self
  # end
end
