#!/bin/bash
mkdir -p src/database src/routes src/services

# Create database/connection.ts
cat > src/database/connection.ts << 'DBEOF'
import Database from 'better-sqlite3';
import path from 'path';

const dbPath = path.join(process.cwd(), 'survey_platform.db');
export const db = new Database(dbPath);
db.pragma('foreign_keys = ON');
DBEOF

# Create database/migrations.ts
cat > src/database/migrations.ts << 'MIGEOF'
import { db } from './connection';

export const migrations = [
  `CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`,
  `CREATE TABLE IF NOT EXISTS surveys (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )`,
  `CREATE TABLE IF NOT EXISTS questions (
    id TEXT PRIMARY KEY,
    survey_id TEXT NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (survey_id) REFERENCES surveys(id)
  )`,
  `CREATE TABLE IF NOT EXISTS responses (
    id TEXT PRIMARY KEY,
    survey_id TEXT NOT NULL,
    user_id TEXT,
    response_data TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (survey_id) REFERENCES surveys(id)
  )`,
  `CREATE TABLE IF NOT EXISTS survey_analytics (
    id TEXT PRIMARY KEY,
    survey_id TEXT NOT NULL,
    total_responses INTEGER DEFAULT 0,
    completion_rate REAL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (survey_id) REFERENCES surveys(id)
  )`
];

export async function runMigrations() {
  for (const migration of migrations) {
    db.exec(migration);
  }
  console.log('✅ Migrations complete');
}
MIGEOF

# Create database/seed.ts
cat > src/database/seed.ts << 'SEEDEOF'
import { db } from './connection';
import bcryptjs from 'bcryptjs';
import { v4 as uuid } from 'uuid';

export async function seedDatabase() {
  const userId = uuid();
  const hashedPassword = await bcryptjs.hash('Test@123', 10);

  db.prepare(`INSERT OR IGNORE INTO users (id, email, password, name)
    VALUES (?, ?, ?, ?)`).run(userId, 'test@example.com', hashedPassword, 'Test User');

  console.log('✅ Seed
mkdir -p src/database src/routes src/services
cat > src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { db } from './database/connection';

const app = express();
const PORT = 3000;

app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Survey Platform API' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
