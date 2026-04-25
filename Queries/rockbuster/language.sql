DROP TABLE IF EXISTS analytics.language CASCADE;

CREATE TABLE analytics.language (
    language_id SERIAL PRIMARY KEY,
    language_name VARCHAR(20) UNIQUE
);

INSERT INTO analytics.language (language_name)
SELECT DISTINCT language_name
FROM analytics._stg_rockbuster;

SELECT 
    * 
FROM analytics.language 
LIMIT 10