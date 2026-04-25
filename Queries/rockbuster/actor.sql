DROP TABLE IF EXISTS analytics.actor CASCADE;

CREATE TABLE analytics.actor (
    actor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    UNIQUE(first_name, last_name)
);

INSERT INTO analytics.actor (first_name, last_name)
SELECT DISTINCT
    actor_first_name,
    actor_last_name
FROM analytics._stg_rockbuster;

SELECT 
    * 
FROM analytics.actor
LIMIT 10