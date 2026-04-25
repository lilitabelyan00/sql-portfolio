DROP TABLE IF EXISTS analytics.category CASCADE;

CREATE TABLE analytics.category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(25) UNIQUE
);

INSERT INTO analytics.category (category_name)
SELECT DISTINCT category_name
FROM analytics._stg_rockbuster;

SELECT 
    * 
FROM analytics.category
LIMIT 10