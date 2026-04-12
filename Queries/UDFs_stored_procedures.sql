CREATE OR REPLACE FUNCTION fn_age_group (
    p_age INT
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT
        CASE
            WHEN p_age < 25 THEN 'Under 25'
            WHEN p_age BETWEEN 25 AND 39 THEN '25–39'
            WHEN p_age BETWEEN 40 AND 59 THEN '40–59'
            ELSE '60+'
        END;
$$;

SELECT
    customer_id,
    age,
    fn_age_group(age) AS age_group
FROM analytics.customers;

CREATE OR REPLACE FUNCTION analytics.fn_customer_tenure (
    p_signup_date DATE
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT
        CASE
            WHEN CURRENT_DATE - p_signup_date < 180 THEN 'New'
            WHEN CURRENT_DATE - p_signup_date < 365 THEN 'Established'
            ELSE 'Loyal'
        END;
$$;

SELECT
    customer_id,
    signup_date,
    analytics.fn_customer_tenure(signup_date) AS tenure_group
FROM analytics.customers;

CREATE OR REPLACE FUNCTION analytics.fn_price_tier (
    p_price NUMERIC
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT
        CASE
            WHEN p_price < 20 THEN 'Low'
            WHEN p_price BETWEEN 20 AND 99.99 THEN 'Mid'
            ELSE 'Premium'
        END;
$$;

SELECT
    product_id,
    product_name,
    price,
    analytics.fn_price_tier(price) AS price_tier
FROM analytics.products;

CREATE OR REPLACE FUNCTION analytics.fn_order_size (
    p_quantity INT
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT
        CASE
            WHEN p_quantity = 1 THEN 'Single Item'
            WHEN p_quantity BETWEEN 2 AND 4 THEN 'Small Basket'
            ELSE 'Large Basket'
        END;
$$;

SELECT
    oi.order_id,
    oi.quantity,
    analytics.fn_order_size(oi.quantity) AS order_size
FROM analytics.order_items oi;

CREATE OR REPLACE FUNCTION analytics.fn_order_activity (
    p_status TEXT
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT
        CASE
            WHEN p_status IN ('cancelled', 'returned') THEN 'Inactive'
            ELSE 'Active'
        END;
$$;

SELECT
    order_id,
    status,
    analytics.fn_order_activity(status) AS activity_state
FROM analytics.orders;

CREATE OR REPLACE FUNCTION analytics.fn_recent_orders (
    p_customer_id INT,
    p_limit       INT
)
RETURNS TABLE (
    order_id    INT,
    order_date  DATE,
    status      TEXT,
    order_total NUMERIC
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        COALESCE(SUM(oi.quantity * p.price), 0) AS order_total
    FROM analytics.orders o
    JOIN analytics.order_items oi ON oi.order_id = o.order_id
    JOIN analytics.products p     ON p.product_id = oi.product_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date, o.status
    ORDER BY o.order_date DESC
    LIMIT GREATEST(p_limit, 0);
$$;

SELECT *
FROM analytics.fn_recent_orders(1, 4);

CREATE OR REPLACE FUNCTION analytics.fn_top_products_by_revenue (
    p_limit INT
)
RETURNS TABLE (
    product_id   INT,
    product_name TEXT,
    revenue      NUMERIC,
    total_qty    BIGINT
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(oi.quantity * p.price), 0) AS revenue,
        COALESCE(SUM(oi.quantity), 0)           AS total_qty
    FROM analytics.products p
    LEFT JOIN analytics.order_items oi
        ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
    ORDER BY revenue DESC, total_qty DESC
    LIMIT GREATEST(p_limit, 0);
$$;

SELECT *
FROM analytics.fn_top_products_by_revenue(10);

CREATE OR REPLACE FUNCTION analytics.fn_customers_by_city (
    p_city_id INT
)
RETURNS TABLE (
    customer_id INT,
    first_name  TEXT,
    last_name   TEXT,
    signup_date DATE
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.signup_date
    FROM analytics.customers c
    WHERE c.city_id = p_city_id;
$$;

SELECT 
    *
FROM analytics.fn_customers_by_city(1);

CREATE OR REPLACE FUNCTION analytics.fn_order_items_detailed (
    p_order_id INT
)
RETURNS TABLE (
    product_id   INT,
    product_name TEXT,
    category     TEXT,
    quantity     INT,
    unit_price  NUMERIC,
    line_total  NUMERIC
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        oi.quantity,
        p.price AS unit_price,
        oi.quantity * p.price AS line_total
    FROM analytics.order_items oi
    JOIN analytics.products p
        ON p.product_id = oi.product_id
    WHERE oi.order_id = p_order_id;
$$;

SELECT 
    *
FROM analytics.fn_order_items_detailed(10);

CREATE OR REPLACE PROCEDURE analytics.sp_upsert_product (
    p_product_id   INT,
    p_product_name TEXT,
    p_category     TEXT,
    p_price        NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_product_id IS NULL THEN
        RAISE EXCEPTION 'product_id cannot be NULL';
    END IF;

    INSERT INTO analytics.products (product_id, product_name, category, price)
    VALUES (p_product_id, p_product_name, p_category, p_price)
    ON CONFLICT (product_id) DO UPDATE
        SET product_name = EXCLUDED.product_name,
            category     = EXCLUDED.category,
            price        = EXCLUDED.price;
END;
$$;

CALL analytics.sp_upsert_product(101, 'USB Cable', 'Accessories', 9.99);

SELECT
	*
FROM analytics.products
WHERE product_id = 101

SELECT
	*
FROM analytics.products
WHERE product_id = 1

CREATE OR REPLACE PROCEDURE analytics.sp_update_order_status (
    p_order_id INT,
    p_status   TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE analytics.orders
    SET status = p_status
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;
END;
$$;

CALL analytics.sp_update_order_status(10, 'shipped');

SELECT
	*
FROM analytics.orders
WHERE order_id = 10;

CREATE OR REPLACE PROCEDURE analytics.sp_delete_customer (
    p_customer_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM analytics.orders
        WHERE customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Cannot delete customer % with existing orders', p_customer_id;
    END IF;

    DELETE FROM analytics.customers
    WHERE customer_id = p_customer_id;
END;
$$;

CALL analytics.sp_delete_customer(19);

CREATE OR REPLACE PROCEDURE analytics.sp_refresh_order_totals ()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE analytics.orders o
    SET status = 'recalculated'
    WHERE EXISTS (
        SELECT 1
        FROM analytics.order_items oi
        WHERE oi.order_id = o.order_id
    );
END;
$$;

CALL analytics.sp_refresh_order_totals();

SELECT 
    * 
FROM analytics.orders 
LIMIT 10

CREATE OR REPLACE VIEW analytics.v_customers_enriched AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.age,
    c.email,
    c.signup_date,
    ci.city_name,
    r.region_name,
    co.country_name
FROM analytics.customers c
LEFT JOIN analytics.cities   ci ON ci.city_id   = c.city_id
LEFT JOIN analytics.regions  r  ON r.region_id  = ci.region_id
LEFT JOIN analytics.countries co ON co.country_id = r.country_id;

SELECT *
FROM analytics.v_customers_enriched;

CREATE OR REPLACE VIEW analytics.v_orders_with_size AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    SUM(oi.quantity) AS total_items,
    analytics.fn_order_size(SUM(oi.quantity)::INT) AS order_size
FROM analytics.orders o
JOIN analytics.order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;

SELECT *
FROM analytics.v_orders_with_size;

CREATE OR REPLACE VIEW analytics.v_product_revenue AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                   AS total_qty,
    SUM(oi.quantity * p.price)         AS revenue,
    analytics.fn_price_tier(p.price)   AS price_tier
FROM analytics.products p
LEFT JOIN analytics.order_items oi
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price;

SELECT *
FROM analytics.v_product_revenue
ORDER BY revenue DESC;

CREATE OR REPLACE VIEW analytics.v_active_orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status
FROM analytics.orders o
WHERE analytics.fn_order_activity(o.status) = 'Active';

SELECT *
FROM analytics.v_active_orders;

CREATE MATERIALIZED VIEW analytics.mv_customers_geography AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ci.city_name,
    r.region_name,
    co.country_name
FROM analytics.customers c
LEFT JOIN analytics.cities   ci ON ci.city_id   = c.city_id
LEFT JOIN analytics.regions  r  ON r.region_id  = ci.region_id
LEFT JOIN analytics.countries co ON co.country_id = r.country_id;

REFRESH MATERIALIZED VIEW analytics.mv_customers_geography;

CREATE MATERIALIZED VIEW analytics.mv_product_revenue AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)           AS total_qty,
    SUM(oi.quantity * p.price) AS revenue
FROM analytics.products p
LEFT JOIN analytics.order_items oi
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category;

REFRESH MATERIALIZED VIEW analytics.mv_product_revenue;

CREATE MATERIALIZED VIEW analytics.mv_active_orders AS
SELECT
    order_id,
    customer_id,
    order_date,
    status
FROM analytics.orders
WHERE analytics.fn_order_activity(status) = 'Active';

REFRESH MATERIALIZED VIEW analytics.mv_active_orders;

