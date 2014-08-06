CREATE TABLE IF NOT EXISTS users (
  id         INTEGER PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name  VARCHAR(255) NOT NULL,
  email      VARCHAR(255) NOT NULL,
  birth_date DATE NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS users_email_index ON users (email);

CREATE TABLE IF NOT EXISTS blog_posts (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL,
  title      VARCHAR(255) NOT NULL,
  content    TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE INDEX IF NOT EXISTS blog_posts_user_id_index ON blog_posts (user_id);
