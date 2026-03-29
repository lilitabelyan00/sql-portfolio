CREATE TEMP TABLE tmp_order_revenue AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.quantity * p.price) AS order_revenue
FROM analytics.orders o
JOIN analytics.order_items oi ON o.order_id = oi.order_id
JOIN analytics.products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.customer_id, o.order_date;

SELECT
    *
FROM tmp_order_revenue
LIMIT 10;

SELECT
    COUNT(*) AS total_orders,
    MIN(order_revenue) AS min_revenue,
    MAX(order_revenue) AS max_revenue,
    AVG(order_revenue) AS avg_revenue
FROM tmp_order_revenue;

SELECT
	customer_id,
	AVG(order_revenue) AS avg_order_revenue
FROM tmp_order_revenue
GROUP BY customer_id;

CREATE TEMP TABLE tmp_customer_spend AS
SELECT
    c.customer_id,
    c.city_id,
    SUM(oi.quantity * p.price) AS total_spend
FROM analytics.customers c
JOIN analytics.orders o ON c.customer_id = o.customer_id
JOIN analytics.order_items oi ON o.order_id = oi.order_id
JOIN analytics.products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.city_id;

SELECT
    city_id,
    AVG(total_spend) AS avg_customer_spend,
    MAX(total_spend) AS max_customer_spend
FROM tmp_customer_spend
GROUP BY city_id;

SELECT
	*
FROM employees 
WHERE salary > (
	SELECT AVG (salary)
	FROM employees
);

SELECT
	customer_id,
	AVG(order_revenue) AS avg_order_revenue
FROM tmp_order_revenue
GROUP BY customer_id
HAVING AVG(order_revenue) >
(
SELECT AVG(order_revenue)
FROM tmp_order_revenue);

CREATE TEMP TABLE tmp_order_revenue AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.quantity * p.price) AS order_revenue
FROM analytics.orders o
JOIN analytics.order_items oi ON o.order_id = oi.order_id
JOIN analytics.products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.customer_id, o.order_date;

--SELECT *
--FROM employees e
--WHERE salary > (
--    SELECT d.target_salary
--    FROM departments d
--    WHERE d.department = e.department);

SELECT
    c.customer_id
FROM analytics.customers c
WHERE (
    SELECT SUM(oi.quantity * p.price)
    FROM analytics.orders o
    JOIN analytics.order_items oi ON o.order_id = oi.order_id
    JOIN analytics.products p ON oi.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
) >
(
    SELECT AVG(customer_total)
    FROM (
        SELECT
            o.customer_id,
            SUM(oi.quantity * p.price) AS customer_total
        FROM analytics.orders o
        JOIN analytics.order_items oi ON o.order_id = oi.order_id
        JOIN analytics.products p ON oi.product_id = p.product_id
        GROUP BY o.customer_id
    ) t
);

SELECT
    employee_id,
    salary,
    (SELECT AVG(salary) FROM employees) AS avg_salary
FROM employees;

SELECT
    order_id,
    order_revenue,
    (
        SELECT AVG(order_revenue)
        FROM tmp_order_revenue
    ) AS avg_order_revenue
FROM tmp_order_revenue;

--SELECT
    e.employee_id,
    e.salary,
    (
        SELECT d.target_salary
        FROM departments d
        WHERE d.department = e.department
    ) AS target_salary
FROM employees e;

SELECT
    c.customer_id,
    (
        SELECT SUM(oi.quantity * p.price)
        FROM analytics.orders o
        JOIN analytics.order_items oi ON o.order_id = oi.order_id
        JOIN analytics.products p ON oi.product_id = p.product_id
        WHERE o.customer_id = c.customer_id
    ) AS customer_spend,
    (
        SELECT AVG(oi.quantity * p.price)
        FROM analytics.orders o
        JOIN analytics.order_items oi ON o.order_id = oi.order_id
        JOIN analytics.products p ON oi.product_id = p.product_id
        JOIN analytics.customers c2 ON o.customer_id = c2.customer_id
        WHERE c2.city_id = c.city_id
    ) AS avg_city_spend
FROM analytics.customers c;


--SELECT
    department,
    avg_salary
FROM (
    SELECT
        department,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) t
WHERE avg_salary > 1000;

SELECT
    customer_id,
    avg_order_revenue
FROM (
    SELECT
        customer_id,
        AVG(order_revenue) AS avg_order_revenue
    FROM tmp_order_revenue
    GROUP BY customer_id
) t
WHERE avg_order_revenue >
      (
          SELECT AVG(order_revenue)
          FROM tmp_order_revenue
      );