-- 01_basic_analysis.sql
-- Table: customers (see 00_create_database.sql)

-- total_customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- churn_count_and_percentage
SELECT churn,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM customers
GROUP BY churn;

-- overall_kpis
SELECT ROUND(AVG(tenure), 1)          AS avg_tenure_months,
       ROUND(AVG(monthly_charges), 2)  AS avg_monthly_charges,
       ROUND(SUM(monthly_charges), 2)  AS total_monthly_revenue
FROM customers;

