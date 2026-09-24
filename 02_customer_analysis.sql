-- 02_customer_analysis.sql
-- Table: customers (see 00_create_database.sql)

-- customers_by_contract
SELECT contract,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM customers
GROUP BY contract
ORDER BY customers DESC;

-- customers_by_internet_service
SELECT internet_service,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM customers
GROUP BY internet_service
ORDER BY customers DESC;

-- customer_segmentation_cte
WITH segmented AS (
    SELECT customer_id, tenure, monthly_charges,
           CASE WHEN tenure <= 12 THEN '1. New (0-12 months)'
                WHEN tenure <= 24 THEN '2. Developing (13-24)'
                WHEN tenure <= 48 THEN '3. Established (25-48)'
                ELSE '4. Loyal (49+)' END AS tenure_segment,
           CASE WHEN monthly_charges < 35 THEN 'Low spend (<35)'
                WHEN monthly_charges < 70 THEN 'Mid spend (35-70)'
                ELSE 'High spend (70+)' END AS spend_segment
    FROM customers
)
SELECT tenure_segment, spend_segment,
       COUNT(*) AS customers,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM segmented
GROUP BY tenure_segment, spend_segment
ORDER BY tenure_segment, MIN(monthly_charges);

-- customers_by_payment_method
SELECT payment_method,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM customers
GROUP BY payment_method
ORDER BY customers DESC;

