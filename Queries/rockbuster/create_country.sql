DROP TABLE IF EXISTS analytics.country CASCADE;

CREATE TABLE analytics.country (
    country_id SERIAL PRIMARY KEY, --autoincrement
    country_name VARCHAR(50) UNIQUE NOT NULL
)