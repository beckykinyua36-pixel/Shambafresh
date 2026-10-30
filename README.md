# ShambaFresh – Task 1 package

ShambaFresh is a web app where **farmers sell** fresh produce directly to **buyers**.
Built with **HTML + CSS + JavaScript** (front end), **Node.js + Express** (back end) and **MySQL** (database).

## What is inside

| Folder / file | What it is |
|---|---|
| `docs/erd.drawio` | Entity Relationship Diagram (7 tables) |
| `docs/wireframes.drawio` | 13 wireframes, one per draw.io page (tabs at the bottom) |
| `docs/API.md` | Every API address, what it needs and what it returns |
| `docs/DATABASE.md` | Data dictionary: every table and column explained |
| `docs/GIT.md` | Git commands and commit messages for submission |
| `backend/` | Server code (`server.js`, `routes/`, `middleware/`, `config/`) |
| `backend/database/schema.sql` | Creates the database and tables |
| `backend/database/shambafresh.sql` | Tables **and** sample data in one file (import in phpMyAdmin / Workbench) |
| `backend/scripts/setup.js` | Creates the tables **and** adds sample data |
| `frontend/` | The website: 13 pages, `css/style.css`, `js/app.js` |

## Pages (front end)

| Page | File | Who can open it |
|---|---|---|
| Home | `index.html` | Everyone |
| Produce catalogue (search, filter, sort) | `catalogue.html` | Everyone |
| Product details | `product.html?id=1` | Everyone |
| Shopping cart | `cart.html` | Everyone |
| Checkout | `checkout.html` | Logged-in buyer |
| My orders | `orders.html` | Logged-in buyer |
| Login / Create account | `login.html` | Everyone |
| About us | `about.html` | Everyone |
| Contact us | `contact.html` | Everyone |
| Our farmers | `farmers.html` | Everyone |
| Farmer dashboard (add/edit products, update orders) | `farmer-dashboard.html` | Farmer |
| Admin panel (users, farmers, orders, messages) | `admin.html` | Admin |

## How to run it (Windows + XAMPP)

1. Install **Node.js** (LTS) from nodejs.org.
2. Open **XAMPP Control Panel** and click **Start** next to **MySQL**.
3. Open a terminal in the `backend` folder:
   ```
   cd backend
   npm install
   npm run setup
   npm start
   ```
4. Open **http://localhost:4000** in Chrome.

`npm run setup` creates the database `shambafresh` and fills it with sample data.
Run it again any time to reset the data.

If your MySQL has a password, edit `backend/.env` (`DB_PASSWORD=...`).

### Demo logins (password for all: `Password123`)

| Role | Email |
|---|---|
| Admin | `admin@shambafresh.co.ke` |
| Buyer | `buyer@shambafresh.co.ke` |
| Farmer | `njeri@shambafresh.co.ke` |

## How it works (short)

- The **website** is plain HTML pages. `frontend/js/app.js` holds the shared code (header, footer, cart, login).
- The pages call the **API** (`/api/...`) with `fetch`. The server reads or writes **MySQL** and answers with JSON.
- **Passwords** are stored hashed (bcrypt). After login the server gives a **token (JWT)** which the browser sends with every request.
- The **cart** lives in the browser (`localStorage`). It becomes an **order** when the buyer checks out.
- Roles: **buyer** (shop), **farmer** (sell), **admin** (manage). The server checks the role on every protected route.

## Changes from the first screens you shared

- The **Login** form no longer asks for "Re-enter Password" (only *Create account* needs it).
- Added the missing pages: About us, Contact us, Our farmers, Product details, Checkout, My orders, Farmer dashboard, Admin.
- The "demo only, saved in this browser" note is gone because accounts are now saved in MySQL.

## Troubleshooting

| Problem | Fix |
|---|---|
| `Setup failed: connect ECONNREFUSED` | MySQL is not running. Start it in XAMPP. |
| `Access denied for user 'root'` | Put your MySQL password in `backend/.env`. |
| Page says "Cannot reach the server" | Run `npm start` and use http://localhost:4000. |
| Port 4000 already used | Change `PORT` in `backend/.env`. |
