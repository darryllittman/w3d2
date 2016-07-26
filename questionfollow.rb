require_relative 'questions_database'
class QuestionFollow
  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        questions_follows.id = ?
    SQL

    return nil unless question_follow.length > 0
    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
        JOIN users
        ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    users.map { |datum| User.new(datum) }
  end

  def QuestionFollow::followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
        JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        ? = question_follows.user_id
    SQL

      questions.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.exectue(<<-SQL, n)

      SELECT
        *
      FROM
        questions
        JOIN question_follows
        ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL

      questions.map { |datum| Question.new(datum) }
  end
end
