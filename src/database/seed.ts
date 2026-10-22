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
