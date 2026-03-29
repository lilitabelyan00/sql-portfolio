CREATE TEMP TABLE tmp_order_products AS (
	SELECT
		o.order_id,
		o.customer_id,
		oi.quantity,
		p.price,
		p.product_name,
		p.category
	FROM analytics.orders o
	INNER JOIN analytics.order_items oi ON (o.order_id = oi.order_id)
	LEFT JOIN  analytics.products p ON (oi.product_id = p.product_id)
)
;

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.city_id,
        SUM(oi.quantity * p.price) AS total_spend
    FROM analytics.customers c
    JOIN analytics.orders o ON c.customer_id = o.customer_id
    JOIN analytics.order_items oi ON o.order_id = oi.order_id
    JOIN analytics.products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.city_id
),
city_agg AS (
    SELECT
        city_id,
        AVG(total_spend) AS avg_city_spend,
        MAX(total_spend) AS max_city_spend
    FROM customer_spend
    GROUP BY city_id
)
SELECT
    *
FROM city_agg;

CREATE TEMP TABLE tmp_sales AS
SELECT *
FROM (
    VALUES
        
        (1,  'A', DATE '2024-01-01', 100, 'online'),
        (2,  'A', DATE '2024-01-02', 120, 'store'),
        (3,  'A', DATE '2024-01-03', 90,  'online'),
        (4,  'A', DATE '2024-01-04', 130, 'store'),

        
        (5,  'B', DATE '2024-01-01', 180, 'store'),
        (6,  'B', DATE '2024-01-02', 200, 'online'),
        (7,  'B', DATE '2024-01-03', 220, 'online'),
        (8,  'B', DATE '2024-01-04', 200, 'store'),

        
        (9,  'C', DATE '2024-01-01', 150, 'online'),
        (10, 'C', DATE '2024-01-02', 150, 'online'),
        (11, 'C', DATE '2024-01-03', 170, 'online'),

        
        (12, 'D', DATE '2024-01-01', 90,  'store'),
        (13, 'D', DATE '2024-01-02', 110, 'store'),

        
        (14, 'E', DATE '2024-01-01', 140, 'store'),
        (15, 'E', DATE '2024-01-02', 160, 'online'),
        (16, 'E', DATE '2024-01-03', 155, 'store')
) AS t(
    sale_id,
    customer_id,
    sale_date,
    amount,
    channel
);

--Avg Amount per Customer
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    AVG(amount) OVER (PARTITION BY customer_id) AS avg_customer_amount
FROM tmp_sales;

SELECT
	sale_id,
    customer_id,
	amount,
	SUM (amount) OVER (PARTITION BY customer_id) AS total_customer_spend
FROM tmp_sales;


SELECT
	sale_id,
    customer_id,
	COUNT (*) OVER (PARTITION BY customer_id) AS transaction_count
FROM tmp_sales;

--Minimum and Maximum Amount per Customer
SELECT
    sale_id,
    customer_id,
    amount,
    MIN(amount) OVER (
        PARTITION BY customer_id
    ) AS min_amount,
    MAX(amount) OVER (
        PARTITION BY customer_id
    ) AS max_amount
FROM tmp_sales;

--Median Amount per Customer
SELECT
    customer_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount)  AS median_amount
FROM tmp_sales
GROUP BY customer_id;

--Percent Rank of Each Transaction
SELECT
    sale_id,
    customer_id,
    amount,
    PERCENT_RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount
    ) AS percent_rank
FROM tmp_sales;

--Cumulative Distribution
SELECT
    sale_id,
    customer_id,
    amount,
    CUME_DIST() OVER (
        PARTITION BY customer_id
        ORDER BY amount
    ) AS cumulative_distribution
FROM tmp_sales;

--Previous Transaction Amount (LAG)
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
    ) AS previous_amount
FROM tmp_sales;

--Next Transaction Amount (LEAD)
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    LEAD(amount) OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
    ) AS next_amount
FROM tmp_sales;

--Change Since Previous Transaction
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    amount
      - LAG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY sale_date
        ) AS amount_change
FROM tmp_sales;

--Last Transaction Amount per Customer
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
	LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_amount
FROM tmp_sales;

--Sequential Ordering (ROW_NUMBER)
SELECT
    sale_id,
    customer_id,
    sale_date,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
    ) AS row_number
FROM tmp_sales;

-- Dense Ranking by Amount (DENSE_RANK)
SELECT
    sale_id,
    customer_id,
    amount,
    DENSE_RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS dense_rank_amount
FROM tmp_sales;

--Ranking by Amount with Gaps (RANK)
SELECT
    sale_id,
    customer_id,
    amount,
    RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS rank_amount
FROM tmp_sales;

--Comparison
SELECT
    sale_id,
    customer_id,
    amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS row_number_amount,
    RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS rank_amount,
    DENSE_RANK() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS dense_rank_amount
FROM tmp_sales
ORDER BY customer_id, amount DESC, sale_id;

--Channels Used by Each Customer (Cumulative)
SELECT
    sale_id,
    customer_id,
    sale_date,
    channel,
    STRING_AGG(channel, ', ') OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
    ) AS channels_used_so_far
FROM tmp_sales;

--Full Channel History per Customer
SELECT
    sale_id,
    customer_id,
    channel,
    STRING_AGG(channel, ', ') OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS full_channel_history
FROM tmp_sales;

--Channel Combination Pattern 1
SELECT
    customer_id,
    STRING_AGG(channel, ', ' ORDER BY channel) AS channel_pattern
    
FROM tmp_sales
GROUP BY customer_id

SELECT
    customer_id,
    STRING_AGG(channel, ', ' ORDER BY channel) AS channel_pattern,
    STRING_AGG(DISTINCT channel, ', ' ORDER BY channel) AS channel_pattern_distinct
FROM tmp_sales
GROUP BY customer_id

WITH customer_channels AS (
    SELECT
        customer_id,
        STRING_AGG(DISTINCT channel, ', ' ORDER BY channel) AS channel_pattern
    FROM tmp_sales
    GROUP BY customer_id
)
SELECT
    channel_pattern,
    COUNT(*) AS customer_count
FROM customer_channels
GROUP BY channel_pattern;

--Running Total (Explicit Frame)
SELECT
    sale_id,
    customer_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM tmp_sales;
