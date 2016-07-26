DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  body TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Michael', 'Jordan'),
  ('Stephen', 'Curry');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('How tall are you?', 'I think you''re really tall. How tall is that?', (SELECT id FROM users WHERE fname = 'Michael' AND lname = 'Jordan'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'How tall are you?'),
    (SELECT id FROM users WHERE fname = 'Stephen' AND lname = 'Curry'));

INSERT INTO
  replies (question_id, user_id, parent_reply_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'How tall are you?'),
    (SELECT id FROM users WHERE fname = 'Stephen' AND lname = 'Curry'),
    (SELECT id FROM replies WHERE NULL),
    'I am enormous!');
