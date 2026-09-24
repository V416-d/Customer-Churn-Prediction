-- 03_churn_analysis.sql
-- Table: customers (see 00_create_database.sql)

-- churn_rate_by_contract
SELECT contract,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;

-- churn_rate_by_service_features
SELECT feature, value, customers, churned,
       ROUND(100.0 * churned / customers, 2) AS churn_rate_pct
FROM (
    SELECT 'internet_service' AS feature, internet_service AS value,
           COUNT(*) AS customers, SUM(churn_flag) AS churned
    FROM customers GROUP BY internet_service
    UNION ALL
    SELECT 'tech_support', tech_support, COUNT(*), SUM(churn_flag)
    FROM customers GROUP BY tech_support
    UNION ALL
    SELECT 'online_security', online_security, COUNT(*), SUM(churn_flag)
    FROM customers GROUP BY online_security
    UNION ALL
    SELECT 'payment_method', payment_method, COUNT(*), SUM(churn_flag)
    FROM customers GROUP BY payment_method
) AS t
ORDER BY feature, churn_rate_pct DESC;

-- avg_charges_and_tenure_by_churn
SELECT churn,
       COUNT(*) AS customers,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,
       ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM customers
GROUP BY churn;

-- payment_method_churn_ranking_window
WITH pm AS (
    SELECT payment_method,
           COUNT(*) AS customers,
           100.0 * SUM(churn_flag) / COUNT(*) AS churn_rate_pct
    FROM customers
    GROUP BY payment_method
)
SELECT payment_method, customers,
       ROUND(churn_rate_pct, 2) AS churn_rate_pct,
       RANK() OVER (ORDER BY churn_rate_pct DESC) AS churn_rank
FROM pm;

-- groups_above_average_churn_having
SELECT contract, payment_method,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract, payment_method
HAVING COUNT(*) >= 100
   AND 100.0 * SUM(churn_flag) / COUNT(*) >
       (SELECT 100.0 * SUM(churn_flag) / COUNT(*) FROM customers)
ORDER BY churn_rate_pct DESC;

