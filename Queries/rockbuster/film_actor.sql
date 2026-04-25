DROP TABLE IF EXISTS analytics.film_actor;

CREATE TABLE analytics.film_actor (
    film_id INT REFERENCES analytics.film(film_id),
    actor_id INT REFERENCES analytics.actor(actor_id),
    PRIMARY KEY (film_id, actor_id)
);

INSERT INTO analytics.film_actor
SELECT DISTINCT
    f.film_id,
    a.actor_id
FROM analytics._stg_rockbuster s
JOIN analytics.film f
  ON f.title = s.title
JOIN analytics.actor a
  ON a.first_name = s.actor_first_name
 AND a.last_name  = s.actor_last_name;

SELECT 
    * 
FROM analytics.film_actor
LIMIT 10