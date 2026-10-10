-- ================================================================
-- LIVEBACKLINK.COM — MySQL DATABASE SCHEMA (v2.0)
-- Target Database: xsdipen_livebacklink
-- User: livebacklinkcom
-- Engine: MySQL 8.0+ / MariaDB 10.5+ (Shared hosting compatible)
-- ================================================================

-- Drop tables in reverse foreign key order if needed
DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS login_logs;
DROP TABLE IF EXISTS order_notifications;
DROP TABLE IF EXISTS sample_links;
DROP TABLE IF EXISTS order_reports;
DROP TABLE IF EXISTS payment_requests;
DROP TABLE IF EXISTS order_phases;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS package_phases;
DROP TABLE IF EXISTS package_items;
DROP TABLE IF EXISTS packages;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS users;

-- 1. USERS TABLE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'client' CHECK (role IN ('admin', 'client')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending')),
    email_verified TINYINT(1) DEFAULT 0,
    verification_token VARCHAR(100),
    reset_token VARCHAR(100),
    reset_token_expires TIMESTAMP,
    company VARCHAR(100),
    phone VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- 2. SERVICES TABLE
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. PACKAGES TABLE (5 Pre-defined tiers)
CREATE TABLE packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    tagline VARCHAR(200),
    total_links INT NOT NULL,
    duration_days INT NOT NULL,
    delivery_phases INT NOT NULL,
    price_usd DECIMAL(10, 2) NOT NULL,
    is_featured TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. PACKAGE_ITEMS TABLE (Service mix per package)
CREATE TABLE package_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT REFERENCES packages(id) ON DELETE CASCADE,
    service_id INT REFERENCES services(id) ON DELETE CASCADE,
    service_name VARCHAR(100) NOT NULL,
    metric_label VARCHAR(100),
    quantity INT NOT NULL
);

-- 5. PACKAGE_PHASES TABLE (Phase structure template per package)
CREATE TABLE package_phases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT REFERENCES packages(id) ON DELETE CASCADE,
    phase_number INT NOT NULL,
    week_label VARCHAR(50) NOT NULL,
    expected_links INT NOT NULL
);

-- 6. ORDERS TABLE
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE RESTRICT,
    package_id INT REFERENCES packages(id) ON DELETE RESTRICT,
    package_name VARCHAR(100) NOT NULL,
    invoice_no VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    target_url VARCHAR(500) NOT NULL,
    anchor_text VARCHAR(500) NOT NULL,
    special_notes TEXT,
    status VARCHAR(30) DEFAULT 'pending_payment' CHECK (status IN (
        'pending_payment',
        'payment_under_review',
        'in_progress',
        'completed',
        'cancelled',
        'refunded'
    )),
    total_phases INT NOT NULL,
    completed_phases INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_invoice_no ON orders(invoice_no);

-- 7. ORDER_PHASES TABLE (Delivery tracking per order)
CREATE TABLE order_phases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    phase_number INT NOT NULL,
    week_label VARCHAR(50) NOT NULL,
    expected_links INT NOT NULL,
    delivered_links INT DEFAULT 0,
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'overdue')),
    due_date DATE,
    completed_at TIMESTAMP,
    notification_sent TINYINT(1) DEFAULT 0,
    links_delivered_count INT DEFAULT 0
);

CREATE INDEX idx_order_phases_order ON order_phases(order_id);

-- 8. PAYMENT_REQUESTS TABLE (Manual bank wire verification)
CREATE TABLE payment_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    transaction_id VARCHAR(100) NOT NULL,
    receipt_path VARCHAR(255),
    receipt_filename VARCHAR(255),
    payment_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP,
    verified_by INT REFERENCES users(id)
);

CREATE INDEX idx_payment_requests_order ON payment_requests(order_id);
CREATE INDEX idx_payment_requests_status ON payment_requests(status);

-- 9. ORDER_REPORTS TABLE (ONE MASTER GOOGLE SHEET URL PER ORDER)
CREATE TABLE order_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    spreadsheet_url VARCHAR(500) NOT NULL,
    title VARCHAR(200) DEFAULT 'LiveBacklink Master Delivery Report',
    description TEXT,
    total_links INT DEFAULT 0,
    is_visible TINYINT(1) DEFAULT 0,
    last_updated_at TIMESTAMP,
    added_by INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_reports_order_id ON order_reports(order_id);

-- 10. SAMPLE_LINKS TABLE (Public showcase links with metrics)
CREATE TABLE sample_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT REFERENCES services(id) ON DELETE SET NULL,
    service_name VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    sample_url VARCHAR(500) NOT NULL,
    domain_name VARCHAR(150) NOT NULL,
    domain_rating INT NOT NULL,
    domain_authority INT NOT NULL,
    monthly_traffic VARCHAR(50) NOT NULL,
    niche VARCHAR(100) NOT NULL,
    anchor_text VARCHAR(150) NOT NULL,
    link_type VARCHAR(50) DEFAULT 'Dofollow Editorial',
    publish_date DATE,
    is_featured TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. ORDER_NOTIFICATIONS TABLE (Live social proof popup data)
CREATE TABLE order_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    action_text VARCHAR(100) DEFAULT 'Just purchased',
    package_name VARCHAR(100) NOT NULL,
    avatar_color VARCHAR(20) DEFAULT '#2563EB',
    is_verified TINYINT(1) DEFAULT 1,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. LOGIN_LOGS TABLE (Security & brute-force audit)
CREATE TABLE login_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    email VARCHAR(150) NOT NULL,
    ip_address VARCHAR(50) NOT NULL,
    user_agent TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'failed', 'blocked')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_login_logs_ip ON login_logs(ip_address, created_at);

-- 13. ACTIVITY_LOGS TABLE (Audit trail of admin & client actions)
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    user_name VARCHAR(100),
    role VARCHAR(20) NOT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. SETTINGS TABLE (Bank, SMTP, SEO, System Configuration)
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    group_name VARCHAR(50) DEFAULT 'general',
    description VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_settings_key ON settings(key);

-- ================================================================
-- INITIAL SEED DATA (PER PRODUCTION PRD v2.0)
-- ================================================================

-- 1. SEED USERS (Admin + Demo Client)
-- Password for admin: admin1234 -> $2y$10$wOq2Z3q1234567890abcdef.abcdefghijklmnopqrstuvwxyz12 (bcrypt)
-- Password for client: client1234 -> $2y$10$c1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdef (bcrypt)
INSERT INTO users (name, email, password_hash, role, status, email_verified, company, phone) VALUES
('Dipen Bishwas', 'admin@livebacklink.com', '$2y$10$FlOKJ9qrJ17smbqirBsPm.YEII.Hzt6Emltedd8uyvmN0nlZOLk7.', 'admin', 'active', 1, 'LiveBacklink Inc.', '+1 (555) 019-2834'),
('Alex Reed', 'alex@seogrowth.io', '$2y$10$smrenoa9ns4DN57/C/.bcOX/ADHhREvIAT4RzqZoUElGbYWGLL68W', 'client', 'active', 1, 'Apex SEO Growth', '+1 (555) 234-5678'),
('Sarah Jenkins', 'sarah@horizonmedia.com', '$2y$10$smrenoa9ns4DN57/C/.bcOX/ADHhREvIAT4RzqZoUElGbYWGLL68W', 'client', 'active', 1, 'Horizon Digital Media', '+1 (555) 876-5432');

-- 2. SEED SERVICES (6 Core offerings, NO "Guest Posts", NO "Profile Backlinks")
INSERT INTO services (name, slug, description, category) VALUES
('Content Publishing', 'content-publishing', 'Bespoke editorial thought leadership written and published on established industry publications.', 'content'),
('High Authority Backlinks', 'high-authority-backlinks', 'Contextual backlink placements on topically aligned domains with DR 30-70+ and verified traffic.', 'authority'),
('Niche Edit Backlinks', 'niche-edits', 'Contextual link insertions placed into aged, indexed articles that already rank in search engines.', 'insertions'),
('High DA Authority Links', 'high-da-authority-links', 'High-authority contextual links from established domains with verified DA 40-60+ authority.', 'da_authority'),
('High Quality Website Links', 'high-quality-website-links', 'Foundational entity trust links from accredited web domains, resource hubs, and platforms.', 'foundational'),
('Press Release Distribution', 'press-release', 'Guaranteed media press release syndication across verified digital news networks.', 'syndication'),
('Digital PR Mentions', 'digital-pr', 'High-impact media citations and editorial press mentions for brand entity authority.', 'pr');

-- 3. SEED PACKAGES (5 Standard Tiers)
INSERT INTO packages (id, name, slug, tagline, total_links, duration_days, delivery_phases, price_usd, is_featured, display_order) VALUES
(1, 'Starter Authority', 'starter-authority', 'Essential authority foundation for new or emerging websites.', 50, 30, 4, 149.00, 0, 1),
(2, 'Growth Authority', 'growth-authority', 'Balanced link power for growing businesses and competitive terms.', 93, 45, 6, 349.00, 1, 2),
(3, 'Professional Authority', 'professional-authority', 'High-impact tiered authority for established brands and agencies.', 155, 60, 8, 699.00, 0, 3),
(4, 'Business Authority', 'business-authority', 'Aggressive search equity for commercial e-commerce and SaaS.', 230, 90, 12, 1299.00, 0, 4),
(5, 'Enterprise Authority', 'enterprise-authority', 'Maximum topical dominance with full digital PR syndication.', 465, 120, 16, 2499.00, 0, 5);



-- 4. SEED PACKAGE_ITEMS
-- Package 1: Starter ($149)
INSERT INTO package_items (package_id, service_id, service_name, metric_label, quantity) VALUES
(1, 1, 'Content Publishing', 'Editorial Placement', 2),
(1, 2, 'High Authority Backlinks', 'DR 30-50', 3),
(1, 4, 'High DA Authority Links', 'DA 40+', 30),
(1, 5, 'High Quality Website Links', 'Accredited Platforms', 15);

-- Package 2: Growth ($349)
INSERT INTO package_items (package_id, service_id, service_name, metric_label, quantity) VALUES
(2, 1, 'Content Publishing', 'Editorial Placement', 5),
(2, 2, 'High Authority Backlinks', 'DR 40-60', 8),
(2, 3, 'Niche Edit Backlinks', 'Aged Indexed URLs', 5),
(2, 4, 'High DA Authority Links', 'DA 40+', 50),
(2, 5, 'High Quality Website Links', 'Accredited Platforms', 25);

-- Package 3: Professional ($699)
INSERT INTO package_items (package_id, service_id, service_name, metric_label, quantity) VALUES
(3, 1, 'Content Publishing', 'Editorial Placement', 10),
(3, 2, 'High Authority Backlinks', 'DR 50-70', 20),
(3, 3, 'Niche Edit Backlinks', 'Aged Indexed URLs', 10),
(3, 4, 'High DA Authority Links', 'DA 50+', 75),
(3, 5, 'High Quality Website Links', 'Accredited Platforms', 40);

-- Package 4: Business ($1,299)
INSERT INTO package_items (package_id, service_id, service_name, metric_label, quantity) VALUES
(4, 1, 'Content Publishing', 'Editorial Placement', 20),
(4, 2, 'High Authority Backlinks', 'DR 60-80', 35),
(4, 3, 'Niche Edit Backlinks', 'Aged Indexed URLs', 20),
(4, 4, 'High DA Authority Links', 'DA 50+', 100),
(4, 5, 'High Quality Website Links', 'Accredited Platforms', 50),
(4, 6, 'Press Release Distribution', 'News Network Syndication', 5);

-- Package 5: Enterprise ($2,499)
INSERT INTO package_items (package_id, service_id, service_name, metric_label, quantity) VALUES
(5, 1, 'Content Publishing', 'Editorial Placement', 40),
(5, 2, 'High Authority Backlinks', 'DR 70+', 60),
(5, 3, 'Niche Edit Backlinks', 'Aged Indexed URLs', 40),
(5, 4, 'High DA Authority Links', 'DA 60+', 200),
(5, 5, 'High Quality Website Links', 'Accredited Platforms', 100),
(5, 6, 'Press Release Distribution', 'News Network Syndication', 15),
(5, 7, 'Digital PR Mentions', 'Media Citations', 10);

-- 5. SEED PACKAGE_PHASES (Week-Based Labels per Section 6)
-- Starter (4 phases)
INSERT INTO package_phases (package_id, phase_number, week_label, expected_links) VALUES
(1, 1, 'Week 1', 12), (1, 2, 'Week 2', 13), (1, 3, 'Week 3', 12), (1, 4, 'Week 4', 13);

-- Growth (6 phases)
INSERT INTO package_phases (package_id, phase_number, week_label, expected_links) VALUES
(2, 1, 'Week 1-2', 15), (2, 2, 'Week 3-4', 16), (2, 3, 'Week 5-6', 15),
(2, 4, 'Week 7-8', 16), (2, 5, 'Week 9-10', 15), (2, 6, 'Week 11-12', 16);

-- Professional (8 phases)
INSERT INTO package_phases (package_id, phase_number, week_label, expected_links) VALUES
(3, 1, 'Week 1-2', 19), (3, 2, 'Week 3-4', 20), (3, 3, 'Week 5-6', 19), (3, 4, 'Week 7-8', 20),
(3, 5, 'Week 9-10', 19), (3, 6, 'Week 11-12', 20), (3, 7, 'Week 13-14', 19), (3, 8, 'Week 15-16', 19);

-- Business (12 phases)
INSERT INTO package_phases (package_id, phase_number, week_label, expected_links) VALUES
(4, 1, 'Week 1-2', 19), (4, 2, 'Week 3-4', 19), (4, 3, 'Week 5-6', 19), (4, 4, 'Week 7-8', 19),
(4, 5, 'Week 9-10', 19), (4, 6, 'Week 11-12', 19), (4, 7, 'Week 13-14', 19), (4, 8, 'Week 15-16', 19),
(4, 9, 'Week 17-18', 19), (4, 10, 'Week 19-20', 19), (4, 11, 'Week 21-22', 19), (4, 12, 'Week 23-24', 21);

-- Enterprise (16 phases)
INSERT INTO package_phases (package_id, phase_number, week_label, expected_links) VALUES
(5, 1, 'Week 1-2', 29), (5, 2, 'Week 3-4', 29), (5, 3, 'Week 5-6', 29), (5, 4, 'Week 7-8', 29),
(5, 5, 'Week 9-10', 29), (5, 6, 'Week 11-12', 29), (5, 7, 'Week 13-14', 29), (5, 8, 'Week 15-16', 29),
(5, 9, 'Week 17-18', 29), (5, 10, 'Week 19-20', 29), (5, 11, 'Week 21-22', 29), (5, 12, 'Week 23-24', 29),
(5, 13, 'Week 25-26', 29), (5, 14, 'Week 27-28', 29), (5, 15, 'Week 29-30', 29), (5, 16, 'Week 31-32', 30);

-- 6. SEED SETTINGS (Manual Bank Details & System Configuration)
-- Bank details strictly per PRD Section 7 (Admin only / after login)
INSERT INTO settings (key, value, group_name, description) VALUES
('bank_account_name', 'Dipen Bishwas', 'bank', 'Bank Account Beneficiary Name'),
('bank_account_number', '30000002930441', 'bank', 'Bank Account Number'),
('bank_routing_number', '028000024', 'bank', 'Bank Routing Number (ABA/ACH)'),
('bank_name', 'JP Morgan Chase NA', 'bank', 'Financial Institution Name'),
('bank_address', '270 Park Avenue, New York, NY 10017', 'bank', 'Bank Branch Address'),
('bank_account_type', 'Checking', 'bank', 'Account Classification'),
('bank_recipient_address', 'Bangladesh, MONGOLBARIA BAZAR, KUSHTIA SADAR, KUSHTIA, 7000', 'bank', 'Account Holder Permanent Address'),
('site_name', 'LiveBacklink', 'general', 'Company Brand Name'),
('support_email', 'support@livebacklink.com', 'general', 'Primary Support Email'),
('maintenance_mode', 'false', 'system', 'Global Maintenance Mode Toggle'),
('live_notification_enabled', 'true', 'marketing', 'Live Social Proof Popup Toggle'),
('live_notification_interval', '15', 'marketing', 'Seconds between live toasts (12-18s)'),
('smtp_host', 'smtp.example.com', 'smtp', 'SMTP Server Host'),
('smtp_port', '587', 'smtp', 'SMTP Port'),
('smtp_user', 'noreply@livebacklink.com', 'smtp', 'SMTP Username'),
('smtp_pass', '', 'smtp', 'SMTP Password'),
('smtp_crypto', 'tls', 'smtp', 'SMTP Encryption');

-- 7. SEED SAMPLE_LINKS (Public sample showcase with metrics)
INSERT INTO sample_links (service_name, title, sample_url, domain_name, domain_rating, domain_authority, monthly_traffic, niche, anchor_text, link_type, publish_date, is_featured, display_order) VALUES
('Content Publishing', 'B2B SaaS Growth Framework', 'https://techgrowthdaily.com/modern-b2b-saas-scaling-strategies', 'techgrowthdaily.com', 68, 62, '48.2k/mo', 'Technology & SaaS', 'enterprise marketing software', 'Dofollow Editorial', '2026-08-14', 1, 1),
('High Authority Backlinks', 'Fintech Cloud Security Analysis', 'https://financeinsiderhub.com/cloud-banking-infrastructure-security', 'financeinsiderhub.com', 72, 65, '85.4k/mo', 'Finance & Banking', 'cyber risk management tools', 'Dofollow Editorial', '2026-08-19', 1, 2),
('Niche Edit Backlinks', 'E-Commerce Conversion Optimization', 'https://retailgrowthreview.com/ecommerce-conversion-rate-benchmarks-guide', 'retailgrowthreview.com', 56, 51, '32.1k/mo', 'Retail & E-Commerce', 'omnichannel retention platform', 'Curated Niche Edit', '2026-08-22', 1, 3),
('High DA Authority Links', 'Supply Chain Software Review', 'https://globaltradeinsights.org/supply-chain-predictive-analytics-tools', 'globaltradeinsights.org', 61, 58, '62.0k/mo', 'Logistics & Supply Chain', 'automated inventory platform', 'High DA Authority Link', '2026-08-25', 1, 4),
('Press Release Distribution', 'Series B Expansion Announcement', 'https://marketwirepulse.com/business-expansion-cloud-ai-infrastructure-round', 'marketwirepulse.com', 75, 70, '120.0k/mo', 'Corporate Business', 'LiveBacklink verified syndicate', 'News Syndication', '2026-08-28', 1, 5);

-- 8. SEED ORDER_NOTIFICATIONS (Live social proof popups)
INSERT INTO order_notifications (client_name, location, action_text, package_name, avatar_color, is_verified, is_active) VALUES
('Michael R.', 'Texas', 'Just ordered', 'Growth Authority Package', '#2563EB', 1, 1),
('Sarah K.', 'California', 'Just purchased', 'Professional Authority Package', '#16A34A', 1, 1),
('David M.', 'New York', 'Just upgraded to', 'Business Authority Package', '#9333EA', 1, 1),
('Emily T.', 'Florida', 'Just ordered', 'Starter Authority Package', '#EA580C', 1, 1),
('James L.', 'Illinois', 'Just purchased', 'Enterprise Authority Package', '#0284C7', 1, 1);

-- ================================================================
-- VERIFICATION QUERY
-- ================================================================
SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;
