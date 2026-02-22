DROP TABLE IF EXISTS customers_raw_text;

CREATE TABLE customers_raw_text 

 SELECT
  raw_phone,
  LENGTH(raw_phone) AS phone_length
FROM customers_raw_text; 

SELECT
	raw_phone,
	REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g') AS digits_only
FROM customers_raw_text;

DROP TABLE IF EXISTS transactions_text_demo;

CREATE TABLE transactions_text_demo (
  transaction_id INTEGER,
  customer_id    INTEGER,
  raw_phone      TEXT,
  category_raw   TEXT,
  quantity       INTEGER,
  price          NUMERIC(10,2)
);

INSERT INTO transactions_text_demo
SELECT
  gs AS transaction_id,
  (RANDOM() * 200)::INT + 1 AS customer_id,

  CASE (gs % 6)
    WHEN 0 THEN '   077600945  '
    WHEN 1 THEN '077-600-045'
    WHEN 2 THEN '(374)-77-600-945'
    WHEN 3 THEN '37477600945'
    WHEN 4 THEN '77600945'
    ELSE '077600945'
  END AS raw_phone,

  CASE (gs % 5)
    WHEN 0 THEN 'Accessories (Promo)'
    WHEN 1 THEN 'Accessories (Test)'
    WHEN 2 THEN 'Electronics (Old)'
    WHEN 3 THEN 'Electronics (Promo)'
    ELSE 'Accessories'
  END AS category_raw,

  (RANDOM() * 5)::INT + 1 AS quantity,
  (RANDOM() * 500 + 10)::NUMERIC(10,2) AS price
FROM generate_series(1, 1000) AS gs;

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT raw_phone) AS distinct_raw_phones,
  COUNT(DISTINCT category_raw) AS distinct_categories
FROM transactions_text_demo;