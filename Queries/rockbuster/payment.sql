DROP TABLE IF EXISTS analytics.payment CASCADE;

CREATE TABLE analytics.payment (
    payment_id SERIAL PRIMARY KEY,
    rental_id INT REFERENCES analytics.rental(rental_id),
    amount NUMERIC(5,2),
    payment_date TIMESTAMP
);

INSERT INTO analytics.payment (
    rental_id,
    amount,
    payment_date
)
SELECT DISTINCT
    r.rental_id,
    s.amount,
    s.payment_date
FROM analytics._stg_rockbuster s
JOIN analytics.rental r
  ON r.rental_date = s.rental_date;

SELECT 
    * 
FROM analytics.payment
LIMIT 10