//==================================
// database_schema.dart
//==================================

final List<String> createTables = [
  //==============================
  // USERS TABLE
  //==============================
  '''
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  api_id INTEGER NOT NULL UNIQUE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT,
  api_token TEXT,
  email_verified_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
  ''',

  //==============================
  // SUBSCRIPTIONS TABLE
  //==============================
  '''
CREATE TABLE IF NOT EXISTS subscriptions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fetched_id INTEGER,
  subscription_name TEXT NOT NULL,
  purchase_date TEXT NOT NULL,
  renew_date TEXT,
  duration_months INTEGER,
  amount_paid REAL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  ''',

  //==============================
  // USER ACTIVITIES TABLE
  //==============================
  '''
CREATE TABLE IF NOT EXISTS user_activities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  activity_type TEXT NOT NULL,
  activity_description TEXT,
  time_performed TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  ''',

  //==============================
  // PROJECTS TABLE (belongs to user)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_name TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  last_opened_at TEXT,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  ''',

  //==============================
  // SELECTED MODULES TABLE (belongs to project)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS selected_modules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  module_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  project_id INTEGER NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  ''',

  //==============================
  // ITEMS TABLE (belongs to selected_modules, stores JSON)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  data TEXT NOT NULL, -- JSON string
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  module_id INTEGER NOT NULL,
  FOREIGN KEY (module_id) REFERENCES selected_modules(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  ''',

  //==============================
  // INSTALLED MODULES TABLE (belongs to user)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS installed_modules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  module_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'module',
  version TEXT,
  status TEXT,
  download_url TEXT,
  installed_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  json_data TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE(user_id, module_id)
);
  ''',

  //==============================
  // MODULES TABLE (available from server)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS modules (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  type TEXT NOT NULL DEFAULT 'module', -- module | template | plugin
  description TEXT,
  version TEXT NOT NULL,
  status TEXT NOT NULL, -- "published" | "reserved" | "deprecated"
  download_url TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
  ''',

  //==============================
  // USER MODULES TABLE (installed locally)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS user_modules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  module_id TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'module',
  installed_version TEXT NOT NULL,
  installed_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (module_id) REFERENCES modules(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE(user_id, module_id)
);
  ''',

  //==============================
  // RESERVED USER MODULES TABLE (wait-list)
  //==============================
  '''
CREATE TABLE IF NOT EXISTS reserved_user_modules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  module_id TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'module',
  reserved_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (module_id) REFERENCES modules(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE(user_id, module_id)
);
  ''',

  //==============================
  // INDEXES FOR PERFORMANCE
  //==============================
  '''
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_selected_modules_project_id ON selected_modules(project_id);
CREATE INDEX IF NOT EXISTS idx_items_module_id ON items(module_id);
CREATE INDEX IF NOT EXISTS idx_installed_modules_user_id ON installed_modules(user_id);
CREATE INDEX IF NOT EXISTS idx_user_modules_user_id ON user_modules(user_id);
CREATE INDEX IF NOT EXISTS idx_reserved_user_modules_user_id ON reserved_user_modules(user_id);
  ''',
];
