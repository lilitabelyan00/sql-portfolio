DROP TABLE IF EXISTS analytics.customer CASCADE;

CREATE TABLE analytics.customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50) UNIQUE,
    active BOOLEAN,
    create_date DATE,
    address_id INT REFERENCES analytics.address(address_id)
);

INSERT INTO analytics.customer (
    first_name,
    last_name,
    email,
    active,
    create_date,
    address_id
)
SELECT DISTINCT
    s.customer_first_name,
    s.customer_last_name,
    s.customer_email,
    s.customer_active,
    s.customer_create_date,
    a.address_id
FROM analytics._stg_rockbuster s
JOIN analytics.address a
  ON a.address = s.customer_address;

SELECT 
    * 
FROM analytics.customer 
LIMIT 10