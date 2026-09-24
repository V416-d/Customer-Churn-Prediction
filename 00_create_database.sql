-- 00_create_database.sql  (MySQL 8+)
CREATE DATABASE IF NOT EXISTS customer_churn;
USE customer_churn;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id        VARCHAR(20) PRIMARY KEY,
    gender             VARCHAR(10),
    senior_citizen     TINYINT,
    partner            VARCHAR(3),
    dependents         VARCHAR(3),
    tenure             INT,
    phone_service      VARCHAR(3),
    multiple_lines     VARCHAR(20),
    internet_service   VARCHAR(15),
    online_security    VARCHAR(25),
    online_backup      VARCHAR(25),
    device_protection  VARCHAR(25),
    tech_support       VARCHAR(25),
    streaming_tv       VARCHAR(25),
    streaming_movies   VARCHAR(25),
    contract           VARCHAR(20),
    paperless_billing  VARCHAR(3),
    payment_method     VARCHAR(30),
    monthly_charges    DECIMAL(8,2),
    total_charges      DECIMAL(10,2),
    churn              VARCHAR(3),
    churn_flag         TINYINT
);

-- Load the cleaned CSV produced by the notebook (adjust the path; requires local_infile enabled)
LOAD DATA LOCAL INFILE 'data/processed/cleaned_customer_churn.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
