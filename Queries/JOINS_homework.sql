--Q1 որ հաճախորդը, որտեղից է պատվեր կատարել
SELECT
	c.customer_id,
	c.first_name,          -- ավելացրի, որ ավելի պարզ լինի թե ով է
    c.last_name,  
	ci.city_name,
	r.region_name,
	co.country_name
FROM analytics.customers c
JOIN analytics.cities ci
  ON c.city_id = ci.city_id
JOIN analytics.regions r
  ON ci.region_id = r.region_id
JOIN analytics.countries co
  ON r.country_id = co.country_id;

--Q2 գտնել այն հաճախորդներին ովքեր պատվեր չեն ունեցել
SELECT
  c.customer_id,
  c.first_name,
  c.last_name
FROM analytics.customers c
LEFT JOIN analytics.orders o
  ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

--պատվերի ավելացում
SELECT
	o.order_id,
	p.product_id,
	oi.quantity
FROM analytics.orders o
JOIN analytics.order_items oi
 ON o.order_id = oi.order_id
 JOIN analytics.products p
 ON oi.product_id = p.product_id;

--Q3 պատվերների ավելացում
SELECT
    o.order_id,
    p.product_id,
    oi.quantity
FROM analytics.orders o
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
JOIN analytics.products p
    ON oi.product_id = p.product_id;

--Q4 ում և որտեղ է վաճառվել
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ci.city_name,
    r.region_name,
    co.country_name,
    ST_Within(cl.geom, cb.geom) AS customer_is_inside_city_boundary
FROM analytics.customers c
JOIN analytics.customer_locations cl  
 ON c.customer_id = cl.customer_id
JOIN analytics.cities       ci        
 ON c.city_id      = ci.city_id
JOIN analytics.regions      r         
 ON ci.region_id   = r.region_id
JOIN analytics.countries    co        
 ON r.country_id   = co.country_id
JOIN analytics.city_boundaries cb    
 ON ci.city_id     = cb.city_id;

--Q5 Եկամուտը երկրի համար
SELECT
	co.country_name,
	SUM(oi.quantity * p.price) AS order_revenue
FROM analytics.orders o
JOIN analytics.order_items oi
  ON o.order_id = oi.order_id
JOIN analytics.products p
  ON oi.product_id = p.product_id
JOIN analytics.customers    c  
 ON o.customer_id = c.customer_id
JOIN analytics.cities       ci 
 ON c.city_id     = ci.city_id
JOIN analytics.regions      r  
 ON ci.region_id  = r.region_id
JOIN analytics.countries    co
 ON r.country_id  = co.country_id
GROUP BY co.country_name
ORDER BY order_revenue DESC;

-- առանց քաղաք
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city_id
FROM analytics.customers c
WHERE c.city_id IS NULL
ORDER BY c.customer_id;