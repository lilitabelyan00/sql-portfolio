DROP TABLE IF EXISTS analytics.address CASCADE;

CREATE TABLE analytics.address (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(50),
    address2 VARCHAR(50),
    district VARCHAR(20),
    postal_code VARCHAR(10),
    phone VARCHAR(20),
    city_id INT REFERENCES analytics.city(city_id),
    UNIQUE(address, postal_code, city_id)
);


INSERT INTO analytics.address (
    address,
    address2,
    district,
    postal_code,
    phone,
    city_id
)
SELECT DISTINCT
    s.customer_address,
    s.customer_address2,
    s.customer_district,
    s.customer_postal_code,
    s.customer_phone,
    c.city_id
FROM analytics._stg_rockbuster s
JOIN analytics.city c
  ON c.city_name = s.customer_city;

SELECT 
    * 
FROM analytics.address 
LIMIT 10