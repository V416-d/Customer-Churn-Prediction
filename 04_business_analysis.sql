-- 04_business_analysis.sql
-- Table: customers (see 00_create_database.sql)

-- revenue_by_churn_status
SELECT churn,
       COUNT(*) AS customers,
       ROUND(SUM(monthly_charges), 2) AS monthly_revenue,
       ROUND(100.0 * SUM(monthly_charges) / SUM(SUM(monthly_charges)) OVER (), 2) AS pct_of_monthly_revenue
FROM customers
GROUP BY churn;

-- churn_by_spend_quartile_ntile
WITH q AS (
    SELECT customer_id, monthly_charges, churn_flag,
           NTILE(4) OVER (ORDER BY monthly_charges) AS spend_quartile
    FROM customers
)
SELECT spend_quartile,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
       ROUND(MIN(monthly_charges), 2) AS min_charge,
       ROUND(MAX(monthly_charges), 2) AS max_charge
FROM q
GROUP BY spend_quartile
ORDER BY spend_quartile;

-- high_revenue_high_churn_segments
SELECT contract, internet_service,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN monthly_charges ELSE 0 END), 2) AS monthly_revenue_of_churned
FROM customers
GROUP BY contract, internet_service
ORDER BY monthly_revenue_of_churned DESC
LIMIT 6;

-- cumulative_churned_revenue_by_tenure_segment
WITH seg AS (
    SELECT CASE WHEN tenure <= 12 THEN '1. 0-12 months'
                WHEN tenure <= 24 THEN '2. 13-24 months'
                WHEN tenure <= 48 THEN '3. 25-48 months'
                ELSE '4. 49+ months' END AS tenure_segment,
           monthly_charges, churn_flag
    FROM customers
), agg AS (
    SELECT tenure_segment,
           SUM(CASE WHEN churn_flag = 1 THEN monthly_charges ELSE 0 END) AS churned_revenue
    FROM seg
    GROUP BY tenure_segment
)
SELECT tenure_segment,
       ROUND(churned_revenue, 2) AS churned_monthly_revenue,
       ROUND(SUM(churned_revenue) OVER (ORDER BY tenure_segment), 2) AS cumulative_churned_revenue
FROM agg
ORDER BY tenure_segment;

-- churned_customers_paying_above_contract_average_join
WITH contract_avg AS (
    SELECT contract, AVG(monthly_charges) AS avg_charge
    FROM customers
    GROUP BY contract
)
SELECT c.contract,
       COUNT(*) AS churned_above_contract_avg,
       ROUND(AVG(c.monthly_charges), 2) AS avg_monthly_charges,
       ROUND(SUM(c.monthly_charges), 2) AS monthly_revenue
FROM customers c
JOIN contract_avg a ON c.contract = a.contract
WHERE c.churn_flag = 1 AND c.monthly_charges > a.avg_charge
GROUP BY c.contract
ORDER BY monthly_revenue DESC;

-- top_10_high_value_churned_customers
SELECT customer_id, contract, internet_service, tenure, monthly_charges, spend_rank
FROM (
    SELECT customer_id, contract, internet_service, tenure, monthly_charges,
           ROW_NUMBER() OVER (ORDER BY monthly_charges DESC, customer_id) AS spend_rank
    FROM customers
    WHERE churn_flag = 1
) AS ranked
WHERE spend_rank <= 10;

