require_relative 'questions_database'

class QuestionLike
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
        JOIN question_likes
        ON questions.id = question_likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
      SQL

      questions.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL

    return nil unless question_like.length > 0
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
        JOIN question_likes
        ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL

    users.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        users
        JOIN question_likes
        ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_likes
        JOIN questions
        ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL

    questions.map { |datum| Question.new(datum) }
  end
end
