DROP TABLE IF EXISTS analytics.film CASCADE;

CREATE TABLE analytics.film (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    release_year INT,
    rental_duration INT,
    rental_rate NUMERIC(4,2),
    length INT,
    replacement_cost NUMERIC(5,2),
    rating VARCHAR(10),
    language_id INT REFERENCES analytics.language(language_id),
    UNIQUE(title, release_year)
);

INSERT INTO analytics.film (
    title,
    description,
    release_year,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    language_id
)
SELECT DISTINCT
    s.title,
    s.description,
    s.release_year,
    s.rental_duration,
    s.rental_rate,
    s.length,
    s.replacement_cost,
    s.rating,
    l.language_id
FROM analytics._stg_rockbuster s
JOIN analytics.language l
  ON l.language_name = s.language_name;

SELECT 
    * 
FROM analytics.film
LIMIT 10