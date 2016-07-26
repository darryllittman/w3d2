require_relative 'questions_database'
class Question
  attr_accessor :title, :body, :user_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    return nil unless question.length > 0
    Question.new(question.first)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.find_by_author_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.user_id = ?
    SQL

    questions.map { |datum| Question.new(datum) }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
        INSERT INTO
          questions (title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      #update
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
        UPDATE
          questions
        SET
          title = ?, body = ?, user_id = ?
        WHERE
          id = ?
      SQL
    end

    self
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.user_id = ?
    SQL

    User.new(user.first)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end
end
