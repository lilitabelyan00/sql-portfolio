SELECT 
    * 
FROM analytics._stg_world_countries 
LIMIT 10

DROP TABLE IF EXISTS analytics.city CASCADE;

CREATE TABLE analytics.city (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    country_id INT REFERENCES analytics.country(country_id),
    UNIQUE (city_name, country_id)
);

INSERT INTO analytics.city (city_name, country_id)
SELECT DISTINCT
    s.customer_city,
    c.country_id
FROM analytics._stg_rockbuster s
JOIN analytics.country c
  ON c.country_name = s.customer_country;

SELECT 
    * 
FROM analytics.city 
LIMIT 10