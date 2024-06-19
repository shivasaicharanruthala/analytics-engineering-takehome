CREATE TYPE IF NOT EXISTS rewards_receipt_status AS ENUM (
  'FINISHED',
  'REJECTED',
  'FLAGGED'
);

CREATE TABLE IF NOT EXISTS users (
  _id UUID PRIMARY KEY,
  state VARCHAR(2),
  created_date TIMESTAMP,
  last_login TIMESTAMP,
  sign_up_source VARCHAR(15),
  role VARCHAR(20),
  active BOOLEAN
);

CREATE TABLE IF NOT EXISTS receipts (
  _id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(_id),
  bonus_points_earned INT,
  bonus_points_earned_reason TEXT,
  create_date TIMESTAMP,
  date_scanned TIMESTAMP,
  finished_date TIMESTAMP,
  modify_date TIMESTAMP,
  points_awarded_date TIMESTAMP,
  points_earned FLOAT,
  purchase_date TIMESTAMP,
  purchased_item_count INT,
  rewards_receipt_status rewards_receipt_status,
  total_spent FLOAT
);

CREATE TABLE IF NOT EXISTS brands (
  _id UUID PRIMARY KEY,
  barcode VARCHAR(20),
  brand_code TEXT,
  category VARCHAR(20),
  category_code TEXT,
  cpg UUID,
  top_brand BOOLEAN,
  name TEXT,
  create_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
  barcode VARCHAR(20) PRIMARY KEY,
  brand_id UUID REFERENCES brands(_id),
  description TEXT,
  final_price FLOAT,
  item_price FLOAT,
  quantity_purchased INT,
  needs_fetch_review BOOLEAN,
  prevent_target_gap_points BOOLEAN,
  needs_fetch_review_reason VARCHAR(15),
  reward_groups TEXT,
  user_flagged_barcode VARCHAR(20),
  user_flagged_new_item BOOLEAN,
  user_flagged_price FLOAT,
  user_flagged_quantity INT
);

CREATE TABLE IF NOT EXISTS transactions (
  receipt_id UUID REFERENCES receipts(_id),
  user_id UUID REFERENCES users(_id),
  barcode VARCHAR(20) REFERENCES items(barcode),
  brand_id UUID REFERENCES brands(_id),
  PRIMARY KEY (receipt_id, barcode)
);
