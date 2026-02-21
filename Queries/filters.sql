ALTER TABLE sales
ADD COLUMN city TEXT;
ALTER TABLE sales
ADD COLUMN category TEXT;
ALTER TABLE sales
ADD COLUMN category TEXT;
SELECT
transaction_id,
	city,
	category,
	total_sales,
	discount,
	CASE
	WHEN total_sales >= 1000 
             AND discount <= 0.10 
             AND category IN ('Electronics', 'Clothing', 'Toys', 'Books')
            THEN 'Premium Electronics'
	ELSE 'Other'
	END AS business_segment
FROM sales
WHERE year = 2023

  SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


ALTER TABLE sales
ADD COLUMN city TEXT;
ALTER TABLE sales
ADD COLUMN category TEXT;
SELECT
   	transaction_id,
	city,
	category,
	total_sales,
	discount,
	CASE
	WHEN total_sales BETWEEN 40000 AND 140000 
         AND discount BETWEEN 0.05 AND 0.25 
         AND category IN ('Fashion', 'Clothing', 'Accessories')
        THEN 'Mid Premium Fashion'
	WHEN discount >= 0.45 
         AND total_sales >= 80000
        THEN 'Heavy Discount High Value'

    WHEN total_sales < 30000 
         OR discount >= 0.40
        THEN 'Promotional / Budget'

    WHEN total_sales < 15000
        THEN 'Everyday Small'

    ELSE 'Other'
END AS business_segment
FROM sales
WHERE YEAR = 2023
  AND total_sales IS NOT NULL
ORDER BY total_sales DESC;