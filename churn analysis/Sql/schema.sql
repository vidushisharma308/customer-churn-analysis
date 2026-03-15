CREATE TABLE customer_dimension (account_id TEXT PRIMARY KEY,
account_name TEXT,
industry TEXT,
country TEXT,
signup_date DATE,
refferal_source TEXT,
plan_tier TEXT CHECK (plan_tier IN ('Basic','Pro','Enterprise')),
seats INT,
is_trial BOOLEAN,
churn_flag BOOLEAN
);
SELECT * FROM customer_dimension

CREATE TABLE churn_fact (churn_event_id TEXT PRIMARY KEY,
account_id TEXT, FOREIGN KEY(account_id) REFERENCES customer_dimension(account_id),
churn_date DATE,
reason_code TEXT,
refund_amount_usd NUMERIC,
preceding_upgrade_flag BOOLEAN,
preceding_downgrade_flag BOOLEAN,
is_reactivation BOOLEAN,
feedback_text TEXT
);
SELECT * FROM churn_fact


