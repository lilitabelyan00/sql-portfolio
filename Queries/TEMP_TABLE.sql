SELECT
	*
FROM analytics.orders;

SELECT
	*
FROM analytics.order_items;

SELECT
	*
FROM analytics.products;


CREATE TEMP TABLE tmp_order_products AS
SELECT
	o.order_id,
	oi.quantity,
	p.price,
	p.product_name,
	p.category
FROM analytics.orders o
LEFT JOIN analytics.order_items oi ON (o.order_id = oi.order_id)
LEFT JOIN analytics.products p ON (oi.product_id = p.product_id)

SELECT
	COUNT(order_id) number_of_orders
FROM tmp_order_products
GROUP BY product_name
ORDER BY number_of_orders DESC;

SELECT
	SUM (quantity) quantity
FROM tmp_order_products
GROUP BY product_name
ORDER BY quantity DESC;