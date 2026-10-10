# LiveBacklink Production Runbook

## Production Scope

The required production workflow is:

1. A client registers and authenticates with a JWT session.
2. The client creates an order. The order, phases, payment request, and report record are created in the shared database.
3. The client uploads a bank-transfer reference and optional receipt file. The payment request is linked to the exact order.
4. An administrator reviews the payment and approves or rejects it. The payment decision, order status, phase activation, and audit log are committed server-side.
5. An administrator updates order details, assigns one master Google Sheet URL, and completes phases in sequence.
6. The client can see the report only when the administrator marks it visible. Later phase updates remain attached to the same order and report.

## Shared Hosting Deployment

1. Use the MySQL database engine configured by the shared-hosting account. The application environment and SQL schema must use the same engine.
2. Create the database and database user in cPanel. Grant the user full privileges on the application database.
3. Configure `backend/.env` with the cPanel database credentials, `MySQLi`, port `3306`, the production base URL, and a long random JWT secret.
4. Open `https://your-domain.com/setup.php` once. The installer reads `backend/.env`, creates the MySQL schema on an empty database, creates the default administrator, and locks itself.
5. After the setup page reports success, delete `setup.php` from the hosting account.
6. Authentication is intentionally direct for the test deployment. No CAPTCHA account, paid service, API key, or external DNS configuration is required.
7. Keep `backend/app`, `backend/system`, and `backend/writable` outside the public web root where the hosting layout permits it. Expose only `backend/public` as the API document root.
8. Ensure `backend/writable` and `backend/writable/uploads/receipts` are writable by PHP. Do not allow script execution from the receipt upload directory.
9. Build the frontend with `npm run build` and upload the contents of `dist` to the website document root.
10. Configure the frontend API URL with `VITE_API_URL` before building when the API is hosted on a separate subdomain or path.
11. Use environment variables for FTP deployment credentials. Never commit or upload deployment passwords in JavaScript utilities.
12. Disable public access to diagnostic scripts, database installers, test scripts, logs, archives, and source maps after deployment. The production package excludes the obsolete SQLite installer `db_install.php`.

## Acceptance Tests

### Authentication

- Register a client and confirm a user row and JWT are returned.
- Confirm client and administrator login work directly with the seeded credentials.
- Confirm the admin login works at `/admin` with the seeded admin email and the current database password.
- Open `/setup.php` on a fresh database and confirm it completes, creates the schema and administrator, and creates `backend/writable/.setup_complete`.
- Log in as a client and confirm client routes reject another user's order ID.
- Log in as an administrator and confirm client credentials cannot access admin routes.
- Confirm expired or invalid JWTs receive HTTP 401.

### Order and Payment

- Create an order and confirm rows exist in `orders`, `order_phases`, `payment_requests`, and `order_reports`.
- Upload a valid receipt and confirm the exact order changes to `payment_under_review`.
- Confirm invalid file types and files larger than 5 MB are rejected.
- Approve a pending payment and confirm the payment becomes `approved`, the order becomes `in_progress`, and phase 1 becomes `in_progress`.
- Reject a pending payment and confirm the order returns to `pending_payment` with an audit log entry.
- Confirm a payment cannot be approved or rejected twice.

### Delivery

- Save a valid Google Sheet URL for an order and confirm it is stored in `order_reports`.
- Confirm an invisible report is not returned to the client.
- Complete phase 1 and confirm delivered links, timestamps, report totals, order status, and audit log are updated.
- Confirm phase 2 cannot be completed before phase 1 and cannot be completed twice.
- Confirm the client sees the same report URL after each completed phase.
- Edit order details as client and administrator and confirm the changes survive a logout and fresh login.

## Current Limitations Requiring a Separate Release

The following administrative modules still require server-backed CRUD implementations before they should be advertised as live features:

- Package create and update
- Sample link create, update, and delete
- Social notification creation
- Orders CSV export
- Payments CSV export
- CRM and catalog persistence

These modules must not report a successful save while only updating browser local storage.

## Security Requirements

- Rotate all database and FTP credentials that have previously existed in repository or deployment scripts.
- Use a unique random JWT secret in production and remove insecure fallback secrets.
- Keep the seeded administrator entry at `/admin`; use the database seed email `admin@livebacklink.com` and the current administrator password, then rotate that password immediately after first login.
- Keep database credentials and `.env` files outside public web access.
- Use HTTPS for both the website and API.
- Add rate limiting to payment upload and administrative mutation endpoints.
- Review web-server rules before launch to block access to `.env`, SQL files, PHP utilities, archives, logs, and writable internals.
- Install PHP CLI or run the PHP syntax and integration checks in CI before each deployment.
