// Register, login and "who am I"
const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/db');
const { signToken, requireAuth } = require('../middleware/auth');
const loginLimiter = require('../middleware/rateLimit');
const router = express.Router();
const emailOk = (e) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);

// POST /api/auth/register
// body: { full_name, email, password, confirm_password, role, phone?, farm_name?, location? }
router.post('/register', async (req, res, next) => {
  try {
    const { full_name, email, password, confirm_password, role, phone, farm_name, location } = req.body;

    if (!full_name || !email || !password || !confirm_password) {
      return res.status(400).json({ error: 'Please fill in all the fields.' });
    }
    if (!emailOk(email)) return res.status(400).json({ error: 'Enter a valid email address.' });
    if (password.length < 8 || !/[A-Za-z]/.test(password) || !/\d/.test(password)) return res.status(400).json({ error: 'Password must have at least 8 characters, with letters and numbers.' });
    if (password !== confirm_password) return res.status(400).json({ error: 'The two passwords do not match.' });

    // Only buyers and farmers can sign up. Admins are created in the database.
    const userRole = role === 'farmer' ? 'farmer' : 'buyer';

    const [exists] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (exists.length) return res.status(409).json({ error: 'That email is already registered.' });

    const hash = await bcrypt.hash(password, 10);
    const [result] = await db.query(
      'INSERT INTO users (full_name, email, password_hash, role, phone) VALUES (?,?,?,?,?)',
      [full_name.trim(), email.trim().toLowerCase(), hash, userRole, phone || null]
    );

    // A farmer also gets a farm profile
    if (userRole === 'farmer') {
      await db.query(
        'INSERT INTO farmers (user_id, farm_name, location, description) VALUES (?,?,?,?)',
        [result.insertId, farm_name || `${full_name.trim()}'s Farm`, location || 'Kenya', 'New farmer on ShambaFresh.']
      );
    }

    const user = { id: result.insertId, full_name: full_name.trim(), email: email.trim().toLowerCase(), role: userRole };
    res.status(201).json({ token: signToken(user), user });
  } catch (err) { next(err); }
});

// POST /api/auth/login   body: { email, password }
router.post('/login', loginLimiter, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'Enter your email and password.' });

    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email.trim().toLowerCase()]);
    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: 'Wrong email or password.' });
    }
    const safe = { id: user.id, full_name: user.full_name, email: user.email, role: user.role };
    res.json({ token: signToken(user), user: safe });
  } catch (err) { next(err); }
});

// GET /api/auth/me  (needs token)
router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await db.query('SELECT id, full_name, email, role, phone FROM users WHERE id = ?', [req.user.id]);
    if (!rows.length) return res.status(404).json({ error: 'User not found.' });
    res.json(rows[0]);
  } catch (err) { next(err); }
});

module.exports = router;
