DROP TABLE IF EXISTS customers_raw_text;
CREATE TABLE customers_raw_text (
  customer_id   INTEGER,
  first_name    TEXT,
  last_name     TEXT,
  raw_phone     TEXT,
  category_raw  TEXT,
  birth_date    DATE
);

SELECT raw_phone, COUNT(*) 
FROM transactions_text_demo 
GROUP BY raw_phone 
ORDER BY COUNT(*) DESC;

SELECT category_raw, COUNT(*) 
FROM transactions_text_demo 
GROUP BY category_raw;

SELECT DISTINCT category_raw, LENGTH(category_raw) as text_len 
FROM transactions_text_demo;

SELECT
	transaction_id,
	SUBSTRING(REGEXP_REPLACE(raw_phone, '\D', '', 'g'), 
	LENGTH(REGEXP_REPLACE(raw_phone, '\D', '', 'g')) - 7) as clean_phone,
	TRIM(REGEXP_REPLACE(category_raw, '\(.*\)', '', 'g')) as clean_category,
	(quantity * price) as revenue
FROM transactions_text_demo;

SELECT 
    TRIM(REGEXP_REPLACE(category_raw, '\(.*\)', '', 'g')) as category_label,
    SUM(quantity * price) as cleaned_revenue,
    (SELECT SUM(quantity * price)
	FROM transactions_text_demo  
	WHERE category_raw = category_raw) as raw_revenue
FROM transactions_text_demo 
GROUP BY 1;

SELECT 
    COUNT(DISTINCT raw_phone) as raw_unique_customers,
    COUNT(DISTINCT SUBSTRING(REGEXP_REPLACE(raw_phone, '\D', '', 'g'), -8)) as clean_unique_customers
FROM transactions_text_demo;