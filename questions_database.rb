require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
include Singleton

  def initialize
    super('./questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end
#
# class User
#   attr_accessor :fname, :lname
#
#   def initialize(options)
#     @id = options['id']
#     @fname = options['fname']
#     @lname = options['lname']
#   end
#
#   def self.find_by_id(id)
#     user = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM
#         users
#       WHERE
#         users.id = ?
#     SQL
#
#     return nil unless user.length > 0
#     User.new(user.first)
#   end
#
#   def self.find_by_name(fname, lname)
#     user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
#       SELECT
#         *
#       FROM
#         users
#       WHERE
#         users.fname = ? AND users.lname = ?
#     SQL
#
#     return nil unless user.length > 0
#     User.new(user.first)
#   end
#
#   def followed_questions
#     QuestionFollow.followed_questions_for_user_id(@id)
#   end
#
#   def average_karma
#     QuestionsDatabase.instance.execute(<<-SQL, @id)
#       SELECT
#         CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT questions.id)
#       FROM
#         questions
#         LEFT OUTER JOIN question_likes
#         ON questions.id = question_likes.question_id
#       WHERE
#         questions.user_id = ?
#     SQL
#   end
#
#   def liked_questions
#     QuestionLike.liked_questions_for_user_id(@id)
#   end
#
#   def authored_questions
#     Question.find_by_author_id(@id)
#   end
#
#   def authored_replies
#     Reply.find_by_user_id(@id)
#   end
#
#   def save
#     if @id.nil?
#       QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
#         INSERT INTO
#           users (fname, lname)
#         VALUES
#           (?, ?)
#       SQL
#       @id = QuestionsDatabase.instance.last_insert_row_id
#     else
#       #update
#       QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
#         UPDATE
#           users
#         SET
#           fname = ?, lname = ?
#         WHERE
#           id = ?
#       SQL
#     end
#
#     self
#   end
# end
#
# class Question
#   attr_accessor :title, :body, :user_id
#
#   def initialize(options)
#     @id = options['id']
#     @title = options['title']
#     @body = options['body']
#     @user_id = options['user_id']
#   end
#
#   def self.find_by_id(id)
#     question = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM
#         questions
#       WHERE
#         questions.id = ?
#     SQL
#
#     return nil unless question.length > 0
#     Question.new(question.first)
#   end
#
#   def self.most_liked(n)
#     QuestionLike.most_liked_questions(n)
#   end
#
#   def self.find_by_author_id(user_id)
#     questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
#       SELECT
#         *
#       FROM
#         questions
#       WHERE
#         questions.user_id = ?
#     SQL
#
#     questions.map { |datum| Question.new(datum) }
#   end
#
#   def save
#     if @id.nil?
#       QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
#         INSERT INTO
#           questions (title, body, user_id)
#         VALUES
#           (?, ?, ?)
#       SQL
#       @id = QuestionsDatabase.instance.last_insert_row_id
#     else
#       #update
#       QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
#         UPDATE
#           questions
#         SET
#           title = ?, body = ?, user_id = ?
#         WHERE
#           id = ?
#       SQL
#     end
#
#     self
#   end
#
#   def self.most_followed(n)
#     QuestionFollow.most_followed_questions(n)
#   end
#
#   def likers
#     QuestionLike.likers_for_question_id(@id)
#   end
#
#   def num_likes
#     QuestionLike.num_likes_for_question_id(@id)
#   end
#
#   def author
#     user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
#       SELECT
#         *
#       FROM
#         users
#       WHERE
#         users.user_id = ?
#     SQL
#
#     User.new(user.first)
#   end
#
#   def followers
#     QuestionFollow.followers_for_question_id(@id)
#   end
#
#   def replies
#     Reply.find_by_question_id(@id)
#   end
# end
#
# class QuestionFollow
#   attr_accessor :question_id, :user_id
#
#   def initialize(options)
#     @id = options['id']
#     @question_id = options['question_id']
#     @user_id = options['user_id']
#   end
#
#   def self.find_by_id(id)
#     question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM
#         question_follows
#       WHERE
#         questions_follows.id = ?
#     SQL
#
#     return nil unless question_follow.length > 0
#     QuestionFollow.new(question_follow.first)
#   end
#
#   def self.followers_for_question_id(question_id)
#     users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
#       SELECT
#         *
#       FROM
#         question_follows
#         JOIN users
#         ON users.id = question_follows.user_id
#       WHERE
#         question_follows.question_id = ?
#     SQL
#
#     users.map { |datum| User.new(datum) }
#   end
#
#   def QuestionFollow::followed_questions_for_user_id(user_id)
#     questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
#       SELECT
#         *
#       FROM
#         question_follows
#         JOIN questions
#         ON question_follows.question_id = questions.id
#       WHERE
#         ? = question_follows.user_id
#     SQL
#
#       questions.map { |datum| Question.new(datum) }
#   end
#
#   def self.most_followed_questions(n)
#     questions = QuestionsDatabase.instance.exectue(<<-SQL, n)
#
#       SELECT
#         *
#       FROM
#         questions
#         JOIN question_follows
#         ON question_follows.question_id = questions.id
#       GROUP BY
#         questions.id
#       ORDER BY
#         COUNT(*) DESC
#       LIMIT ?
#     SQL
#
#       questions.map { |datum| Question.new(datum) }
#   end
# end
#
# class Reply
#   attr_accessor :question_id, :user_id, :parent_reply_id, :body
#
#   def initialize(options)
#     @id = options['id']
#     @question_id = options['question_id']
#     @user_id = options['user_id']
#     @parent_reply_id = options['parent_reply_id']
#     @body = options['body']
#   end
#
#   def self.find_by_id(id)
#     reply = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM
#         replies
#       WHERE
#         replies.id = ?
#     SQL
#
#     return nil unless reply.length > 0
#     Reply.new(reply.first)
#   end
#
#   def self.find_by_user_id(user_id)
#     replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
#       SELECT
#         *
#       FROM
#         replies
#       WHERE
#         replies.user_id = ?
#     SQL
#
#     return nil unless replies.length > 0
#     replies.map { |datum| Reply.new(datum) }
#   end
#
#   def self.find_by_question_id(question_id)
#     replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
#       SELECT
#         *
#       FROM
#         replies
#       WHERE
#         replies.question_id = ?
#     SQL
#
#     return nil unless replies.length > 0
#     replies.map { |datum| Reply.new(datum) }
#   end
#
#   def save
#     if @id.nil?
#       QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_reply_id, @body)
#         INSERT INTO
#           replies (question_id, user_id, parent_reply_id, body)
#         VALUES
#           (?, ?, ?, ?)
#       SQL
#       @id = QuestionsDatabase.instance.last_insert_row_id
#     else
#       #update
#       QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_reply_id, @body, @id)
#         UPDATE
#           replies
#         SET
#           question_id = ?, user_id = ?, parent_reply_id = ?, body = ?
#         WHERE
#           id = ?
#       SQL
#     end
#
#     self
#   end
#
#   def author
#     User.find_by_id(@user_id)
#   end
#
#   def question
#     Question.find_by_id(@question_id)
#   end
#
#   def parent_reply
#     self.find_by_id(@parent_reply_id)
#   end
#
#   def child_replies
#     replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
#       SELECT
#         *
#       FROM
#         replies
#       WHERE
#         replies.parent_reply_id = ?
#       SQL
#
#     replies.map { |datum| Reply.new(datum) }
#   end
# end
#
# class QuestionLike
#   attr_accessor :user_id, :question_id
#
#   def initialize(options)
#     @id = options['id']
#     @user_id = options['user_id']
#     @question_id = options['question_id']
#   end
#
#   def self.most_liked_questions(n)
#     questions = QuestionsDatabase.instance.execute(<<-SQL, n)
#       SELECT
#         *
#       FROM
#         questions
#         JOIN question_likes
#         ON questions.id = question_likes.question_id
#       GROUP BY
#         questions.id
#       ORDER BY
#         COUNT(*) DESC
#       LIMIT
#         ?
#       SQL
#
#       questions.map { |datum| Question.new(datum) }
#   end
#
#   def self.find_by_id(id)
#     question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM
#         question_likes
#       WHERE
#         question_likes.id = ?
#     SQL
#
#     return nil unless question_like.length > 0
#     QuestionLike.new(question_like.first)
#   end
#
#   def self.likers_for_question_id(question_id)
#     users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
#       SELECT
#         *
#       FROM
#         users
#         JOIN question_likes
#         ON question_likes.user_id = users.id
#       WHERE
#         question_likes.question_id = ?
#     SQL
#
#     users.map { |datum| User.new(datum) }
#   end
#
#   def self.num_likes_for_question_id(question_id)
#     QuestionsDatabase.instance.execute(<<-SQL, question_id)
#       SELECT
#         COUNT(*)
#       FROM
#         users
#         JOIN question_likes
#         ON question_likes.user_id = users.id
#       WHERE
#         question_likes.question_id = ?
#     SQL
#   end
#
#   def self.liked_questions_for_user_id(user_id)
#     questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
#       SELECT
#         *
#       FROM
#         question_likes
#         JOIN questions
#         ON questions.id = question_likes.question_id
#       WHERE
#         question_likes.user_id = ?
#     SQL
#
#     questions.map { |datum| Question.new(datum) }
#   end
# end
