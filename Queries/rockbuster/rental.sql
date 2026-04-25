DROP TABLE IF EXISTS analytics.rental CASCADE;

CREATE TABLE analytics.rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date TIMESTAMP,
    return_date TIMESTAMP,
    customer_id INT REFERENCES analytics.customer(customer_id),
    film_id INT REFERENCES analytics.film(film_id),
    staff_id INT REFERENCES analytics.staff(staff_id)
);

INSERT INTO analytics.rental (
    rental_date,
    return_date,
    customer_id,
    film_id,
    staff_id
)
SELECT DISTINCT
    s.rental_date,
    s.return_date,
    c.customer_id,
    f.film_id,
    st.staff_id
FROM analytics._stg_rockbuster s
JOIN analytics.customer c ON c.email = s.customer_email
JOIN analytics.film f ON f.title = s.title
JOIN analytics.staff st ON st.email = s.staff_email;

SELECT 
    * 
FROM analytics.rental
LIMIT 10