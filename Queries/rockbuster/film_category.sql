DROP TABLE IF EXISTS analytics.film_category;

CREATE TABLE analytics.film_category (
    film_id INT REFERENCES analytics.film(film_id),
    category_id INT REFERENCES analytics.category(category_id),
    PRIMARY KEY (film_id, category_id)
);

INSERT INTO analytics.film_category
SELECT DISTINCT
    f.film_id,
    c.category_id
FROM analytics._stg_rockbuster s
JOIN analytics.film f
  ON f.title = s.title
JOIN analytics.category c
  ON c.category_name = s.category_name;

SELECT 
    * 
FROM analytics.film_category
LIMIT 10