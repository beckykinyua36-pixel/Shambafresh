// Run with:  npm run setup
// 1) creates the database and tables from database/schema.sql
// 2) adds sample users, farms, categories and the 8 products from the wireframes
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

(async () => {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    port: process.env.DB_PORT || 3306,
    charset: 'utf8mb4',
    multipleStatements: true
  });

  console.log('Creating database and tables...');
  const sql = fs.readFileSync(path.join(__dirname, '..', 'database', 'schema.sql'), 'utf8');
  await conn.query(sql);
  await conn.query('USE ' + conn.escapeId(process.env.DB_NAME || 'shambafresh'));

  console.log('Adding sample data...');
  const hash = await bcrypt.hash('Password123', 10);

  // Users: 1 admin, 1 buyer, 7 farmers
  const users = [
    ['Site Admin',      'admin@shambafresh.co.ke',  'admin',  '0700000001'],
    ['Brian Otieno',    'buyer@shambafresh.co.ke',  'buyer',  '0700000002'],
    ['Esther Njeri',    'njeri@shambafresh.co.ke',  'farmer', '0722000001'],
    ['Hassan Mwinyi',   'mwinyi@shambafresh.co.ke', 'farmer', '0722000002'],
    ['Faith Chebet',    'chebet@shambafresh.co.ke', 'farmer', '0722000003'],
    ['David Mutua',     'mutua@shambafresh.co.ke',  'farmer', '0722000004'],
    ['Rose Wambui',     'wambui@shambafresh.co.ke', 'farmer', '0722000005'],
    ['Joseph Kariuki',  'kariuki@shambafresh.co.ke','farmer', '0722000006'],
    ['Beatrice Nyamu',  'nyamu@shambafresh.co.ke',  'farmer', '0722000007']
  ];
  for (const u of users) {
    await conn.query(
      'INSERT INTO users (full_name, email, password_hash, role, phone) VALUES (?,?,?,?,?)',
      [u[0], u[1], hash, u[2], u[3]]
    );
  }

  // Farms (user ids 3..9)
  const farms = [
    [3, 'Njeri Greens',         'Limuru',      'Leafy greens and carrots grown in the cool Limuru highlands.', 1],
    [4, 'Pwani Fresh Farm',     'Kilifi',      'Coconuts and tropical produce from the Kenyan coast.', 1],
    [5, 'Chebet Highlands',     'Uasin Gishu', 'Pulses and grains grown on family land near Eldoret.', 1],
    [6, 'Mutua Dryland Farm',   'Kitui',       'Drought-tolerant sorghum and millet from eastern Kenya.', 1],
    [7, 'Wambui Orchards',      "Murang'a",    'Hass avocado orchards on the slopes of the Aberdares.', 1],
    [8, 'Kariuki Roots',        'Meru',        'Arrow roots, yams and other root crops from Meru.', 1],
    [9, 'Rift Valley Co-op',    'Nakuru',      'A cooperative of 60 growers supplying cabbages and kale.', 1]
  ];
  for (const f of farms) {
    await conn.query('INSERT INTO farmers (user_id, farm_name, location, description, verified) VALUES (?,?,?,?,?)', f);
  }

  // Categories
  const cats = [
    ['Vegetables',       'Crisp, green and local',       '🥬'],
    ['Fruits',           'Ripe and ready to eat',        '🥑'],
    ['Grains & pulses',  'Protein-rich pantry basics',   '🌾'],
    ['Roots & tubers',   'Hearty and filling',           '🥔']
  ];
  for (const c of cats) {
    await conn.query('INSERT INTO categories (name, description, icon) VALUES (?,?,?)', c);
  }

  // Products
  // [farmer_id, category_id, name, description, price, unit, stock, badge, icon]
  const products = [
    [1, 1, 'Fresh Spinach',   'Tender spinach leaves, washed and bundled.',                          40,  'bunch', 180, 'Fresh today',  '🥬'],
    [2, 2, 'Coastal Coconuts','Mature coconuts from the Kilifi coast, full of sweet water.',          60,  'piece', 300, 'Coastal',      '🥥'],
    [3, 3, 'Green Grams',     'Clean, sorted green grams (ndengu) from Uasin Gishu.',                180, 'kg',    250, 'Protein-rich', '🫘'],
    [4, 3, 'Sorghum',         'Whole-grain sorghum from Kitui, ideal for porridge and ugali.',       85,  'kg',    400, 'Staple',       '🌾'],
    [5, 2, 'Hass Avocados',   "Creamy, rich Hass avocados from Murang'a.",                           25,  'piece', 500, 'Popular',      '🥑'],
    [6, 4, 'Arrow Roots',     'Fresh arrow roots (nduma), boiled or fried.',                         110, 'kg',    100, 'Farm fresh',   '🥔'],
    [7, 1, 'Cabbages',        'Firm, heavy cabbages from the Rift Valley.',                          50,  'piece', 350, 'Good value',   '🥬'],
    [1, 1, 'Carrots',         'Sweet, crunchy Limuru carrots.',                                      90,  'kg',    140, 'Crunchy',      '🥕']
  ];
  for (const p of products) {
    await conn.query(
      'INSERT INTO products (farmer_id, category_id, name, description, price, unit, stock_qty, badge, icon) VALUES (?,?,?,?,?,?,?,?,?)',
      p
    );
  }

  // One sample order so "My orders" and the dashboards are not empty
  const [o] = await conn.query(
    "INSERT INTO orders (buyer_id, total_amount, status, delivery_address, phone, payment_method) VALUES (2, 320, 'confirmed', 'Westlands, Nairobi', '0700000002', 'mpesa')"
  );
  await conn.query('INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?,?,?,?)', [o.insertId, 1, 3, 40]);
  await conn.query('INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?,?,?,?)', [o.insertId, 5, 2, 25]);

  console.log('\nDone! Demo logins (password for all: Password123)');
  console.log('  admin  : admin@shambafresh.co.ke');
  console.log('  buyer  : buyer@shambafresh.co.ke');
  console.log('  farmer : njeri@shambafresh.co.ke');
  await conn.end();
})().catch((err) => {
  console.error('Setup failed:', err.message);
  console.error('Is MySQL running (XAMPP > Start MySQL) and are the .env details correct?');
  process.exit(1);
});
