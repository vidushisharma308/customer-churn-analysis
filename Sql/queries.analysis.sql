#analysis

SELECT * FROM churn_fact
SELECT * FROM usage_fact
SELECT * FROM support_interaction_fact
SELECT * FROM subscription_revenue_fact
SELECT * FROM customer_dimension

#accounts_per_industry
SELECT industry, COUNT(account_id) AS total_accounts FROM customer_dimension
GROUP BY industry
ORDER BY total_accounts DESC

#accounts_per_country
SELECT country, COUNT(account_id) AS total_accounts FROM customer_dimension
GROUP BY country
ORDER BY total_accounts DESC


#churncounts_per_industry
SELECT industry, COUNT(account_id) AS total_churns FROM customer_dimension
WHERE churn_flag = TRUE
GROUP BY industry
ORDER BY total_churns DESC

#churncounts_per_country
SELECT country, COUNT(account_id) AS total_churns FROM customer_dimension
WHERE churn_flag = TRUE
GROUP BY country
ORDER BY total_churns DESC


#churnrate_per_industry
SELECT industry, COUNT(CASE WHEN churn_flag=TRUE THEN 1.0 END)*100.00/COUNT(account_id)
AS churn_rate FROM customer_dimension
GROUP BY industry
ORDER BY churn_rate DESC

#churnrate_per_country
SELECT country, COUNT(CASE WHEN churn_flag=TRUE THEN 1.0 END) * 100.00/COUNT(account_id)
AS churn_rate FROM customer_dimension
GROUP BY country
ORDER BY churn_rate DESC

#signup_date
SELECT DISTINCT(signup_date) FROM customer_dimension

SELECT 
DATE_TRUNC('month', signup_date) AS month,
COUNT(account_id) AS total_signups
FROM customer_dimension
GROUP BY month
ORDER BY month;

#churnrate_per_month
SELECT 
DATE_TRUNC('month', signup_date) AS month,
COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) * 100.0 / COUNT(account_id) AS churn_rate
FROM customer_dimension
GROUP BY month
ORDER BY month;

#Cohort_analysis:
SELECT DATE_TRUNC('month', signup_date) AS month,
COUNT(account_id) AS total_users,
COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) AS churned_users,ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) * 100.0 / COUNT(account_id), 2)
AS churn_rate
FROM customer_dimension
GROUP BY month
ORDER BY month

SELECT *
FROM customer_dimension
WHERE DATE_TRUNC('month', signup_date) = '2023-02-01';

SELECT 
country,
COUNT(*) AS total_users,
COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) AS churned_users,
ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_dimension
WHERE DATE_TRUNC('month', signup_date) = '2023-02-01'
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY churn_rate DESC;

SELECT 
country,
COUNT(*) AS total_users,
ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM customer_dimension
GROUP BY country
HAVING COUNT(*) >= 20
ORDER BY churn_rate DESC;


#germany_analysis
SELECT 
country,
plan_tier,
COUNT(*) AS total_users,
ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END)*100.0/COUNT(*),2) AS churn_rate
FROM customer_dimension
WHERE country='Germany'
GROUP BY country, plan_tier
ORDER BY country, churn_rate DESC;

SELECT 
refferal_source,
COUNT(*) AS total_users,
COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) AS churned_users,
ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END)*100.0/COUNT(*),2) AS churn_rate
FROM customer_dimension
WHERE country = 'Germany'
GROUP BY refferal_source
HAVING COUNT(*) >= 5
ORDER BY churn_rate DESC;


#churn_users_by_lifetime
SELECT CASE WHEN f.churn_date - c.signup_date < 25 THEN 'Below 25'
WHEN f.churn_date - c.signup_date BETWEEN 25 AND 50 THEN '25 to 50'
WHEN f.churn_date - c.signup_date BETWEEN 51 AND 100 THEN '50 to 100'
ELSE 'Above 100'
END AS lifetime_bucket,
COUNT(c.account_id) AS churned_users FROM customer_dimension c
JOIN churn_fact f ON c.account_id = f.account_id
GROUP BY lifetime_bucket
ORDER BY 
MIN(f.churn_date - c.signup_date); 


#tenure_wise_churn_rate
WITH tenure_data AS (SELECT c.account_id,
EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.signup_date)) * 12 + 
EXTRACT(MONTH FROM AGE(CURRENT_DATE, c.signup_date)) AS tenure_months,
CASE 
WHEN f.churn_date IS NOT NULL THEN 1ELSE 0 END AS churn_flag
FROM customer_dimension c LEFT JOIN churn_fact f ON c.account_id = f.account_id)
SELECT CASE WHEN tenure_months <= 12 THEN '0-12 Months'
WHEN tenure_months <= 24 THEN '12-24 Months'
WHEN tenure_months <= 36 THEN '24-36 Months'
ELSE '36+ Months'
END AS tenure_bucket,
COUNT(*) AS total_users,
COUNT(CASE WHEN churn_flag = 1 THEN 1 END) AS churned_users,
ROUND( COUNT(CASE WHEN churn_flag = 1 THEN 1 END) * 100.0 / COUNT(*), 2 ) AS
churn_rate
FROM tenure_data
GROUP BY tenure_bucket
ORDER BY tenure_bucket;


#plan_wise_churn_rate
SELECT plan_tier, COUNT(account_id) AS total_users,
COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) AS churned_users,
ROUND(COUNT(CASE WHEN churn_flag = TRUE THEN 1 END) * 100.0 / COUNT(account_id), 2) AS churn_rate
FROM customer_dimension
GROUP BY plan_tier
ORDER BY churn_rate DESC;


#usage_fact_analysis
WITH user_usage AS (SELECT u.subscription_id, SUM(u.usage_count) AS total_usage
FROM usage_fact_modified u GROUP BY u.subscription_id),
usage_bucket AS (SELECT subscription_id, total_usage,
CASE WHEN total_usage < 30 THEN 'Low'
WHEN total_usage < 70 THEN 'Medium'
ELSE 'High' END AS usage_level FROM user_usage)
SELECT ub.usage_level,
COUNT(*) AS total_users,
COUNT(CASE WHEN f.churn_date IS NOT NULL THEN 1 END) AS churned_users,
ROUND(COUNT(CASE WHEN f.churn_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*),2) 
AS churn_rate FROM usage_bucket ub
LEFT JOIN subscription_revenue_fact s ON ub.subscription_id = s.subscription_id
LEFT JOIN churn_fact f ON s.account_id = f.account_id
GROUP BY ub.usage_level
ORDER BY ub.usage_level;


#churn_by_supportinteraction
SELECT CASE WHEN f.churn_date IS NOT NULL THEN 'Churned'
ELSE 'Active' END AS user_status,
AVG(s.first_response_time_minutes_mod) AS avg_response_time,
AVG(s.satisfaction_score_mod) AS avg_satisfaction,
COUNT(*) AS total_tickets
FROM support_interaction_fact_modified s
LEFT JOIN churn_fact f
ON s.account_id = f.account_id
GROUP BY user_status;

#revenueimpact
SELECT 
    CASE 
        WHEN f.churn_date IS NOT NULL THEN 'Churned'
        ELSE 'Active'
    END AS user_status,

    COUNT(DISTINCT s.account_id) AS users,

    SUM(s.mrr_amount) AS total_revenue,

    AVG(s.mrr_amount) AS avg_revenue

FROM subscription_revenue_fact s

LEFT JOIN churn_fact f
    ON s.account_id = f.account_id

GROUP BY user_status;


#revenueimpact_by_country
SELECT 
    c.country,
    COUNT(DISTINCT s.account_id) AS users,
    SUM(s.mrr_amount) AS total_revenue,
    ROUND(AVG(s.mrr_amount), 2) AS avg_revenue_per_user
FROM subscription_revenue_fact s
JOIN customer_dimension c 
    ON s.account_id = c.account_id
GROUP BY c.country
ORDER BY total_revenue DESC;


#revenue_by_industry
SELECT 
    c.industry,
    COUNT(DISTINCT s.account_id) AS users,
    SUM(s.mrr_amount) AS total_revenue,
    ROUND(AVG(s.mrr_amount), 2) AS avg_revenue_per_user
FROM subscription_revenue_fact s
JOIN customer_dimension c 
    ON s.account_id = c.account_id
GROUP BY c.industry
ORDER BY total_revenue DESC;




WITH account_resolution AS (
SELECT MAX(resolution_time_hours) AS resolution_time_hours
FROM support_interaction_fact
GROUP BY account_id)
SELECT CASE WHEN ar.resolution_time_hours <= 24 THEN '0-24 hrs'
WHEN ar.resolution_time_hours <= 48 THEN '24-48 hrs'
ELSE '48+ hrs'
END AS resolution_time_hours_bucket,
COUNT(DISTINCT ar.account_id) AS accounts,
COUNT(DISTINCT CASE 
WHEN c.account_id IS NOT NULL THEN ar.account_id 
END) AS accounts_churned,
ROUND (COUNT(DISTINCT CASE 
END) * 100.0 / COUNT(DISTINCT ar.account_id), 2) AS churn_rate
FROM account_resolution ar
LEFT JOIN churn_fact c 
ON ar.account_id = c.account_id
GROUP BY resolution_time_hours_bucket
ORDER BY resolution_time_hours_bucket;

WITH account_resolution AS (
    SELECT 
        account_id,
        MAX(resolution_time_hours) AS resolution_time_hours
    FROM support_interaction_fact
    GROUP BY account_id
)

SELECT 
    CASE 
        WHEN ar.resolution_time_hours <= 24 THEN '0-24 hrs'
        WHEN ar.resolution_time_hours <= 48 THEN '24-48 hrs'
        ELSE '48+ hrs'
    END AS resolution_time_hours_bucket,

    COUNT(DISTINCT ar.account_id) AS accounts,

    COUNT(DISTINCT CASE 
        WHEN c.account_id IS NOT NULL THEN ar.account_id 
    END) AS accounts_churned,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN c.account_id IS NOT NULL THEN ar.account_id 
        END) * 100.0 
        / COUNT(DISTINCT ar.account_id), 
    2) AS churn_rate

FROM account_resolution ar
LEFT JOIN churn_fact c 
    ON ar.account_id = c.account_id

GROUP BY resolution_time_hours_bucket
ORDER BY resolution_time_hours_bucket;




SELECT MIN(resolution_time_hours), MAX(resolution_time_hours)
FROM support_interaction_fact;

UPDATE support_interaction_fact
SET resolution_time_hours = 1
WHERE resolution_time_hours < 1;



WITH account_resolution AS (SELECT account_id,
AVG(resolution_time_hours) AS resolution_time_hours FROM support_interaction_fact
GROUP BY account_id)
SELECT CASE WHEN resolution_time_hours <= 24 THEN '0-24 hrs'
WHEN resolution_time_hours <= 48 THEN '24-48 hrs'
ELSE '48+ hrs'
END AS resolution_hours,
COUNT(*) AS accounts,
COUNT(CASE WHEN c.account_id IS NOT NULL THEN 1 END) AS accounts_churned,
ROUND(COUNT(CASE WHEN c.account_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) 
AS churn_rate
FROM account_resolution ar
LEFT JOIN churn_fact c ON ar.account_id = c.account_id
GROUP BY resolution_hours
ORDER BY resolution_hours;

