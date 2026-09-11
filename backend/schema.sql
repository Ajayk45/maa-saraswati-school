CREATE TABLE IF NOT EXISTS admin_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(80) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS site_content (
  id INTEGER PRIMARY KEY DEFAULT 1,
  hero_title TEXT NOT NULL,
  hero_text TEXT NOT NULL,
  about_title TEXT NOT NULL,
  about_text TEXT NOT NULL,
  academics_title TEXT NOT NULL,
  academics_text TEXT NOT NULL,
  student_life_title TEXT NOT NULL,
  student_life_text TEXT NOT NULL,
  rules_title TEXT NOT NULL,
  rules_text TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  event_date DATE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inquiries (
  id SERIAL PRIMARY KEY,
  parent_name VARCHAR(120) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  student_name VARCHAR(120) NOT NULL,
  class_name VARCHAR(60) NOT NULL,
  message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  email VARCHAR(160),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admissions (
  id SERIAL PRIMARY KEY,
  student_name VARCHAR(120) NOT NULL,
  father_name VARCHAR(120) NOT NULL,
  mother_name VARCHAR(120),
  dob DATE,
  class_name VARCHAR(60) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  email VARCHAR(160),
  address TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'Pending'
    CHECK (status IN ('Pending', 'Approved', 'Rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admissions_created_at
  ON admissions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admissions_status
  ON admissions(status);
