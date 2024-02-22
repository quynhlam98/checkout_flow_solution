WITH total_carts_created AS (
SELECT * 
FROM checkout_carts),
total_checkout_attempts AS (
SELECT cc.user_id,
       ca.action_name,
       ca.action_date
FROM checkout_carts cc
LEFT JOIN checkout_actions ca
ON cc.user_id = ca.user_id
WHERE ca.action_name LIKE '%checkout%'
AND ca.action_date BETWEEN '2022-07-01' AND '2023-01-31'),
successful_checkout_attempts AS (
SELECT *
FROM total_checkout_attempts 
WHERE action_name LIKE '%success%'),
count_total_carts_created AS 
(SELECT action_date,
        COUNT(*) AS count_total_carts_created
FROM total_carts_created 
GROUP BY action_date),
count_total_checkout_attempts AS (
SELECT action_date,
       COUNT(*) AS count_total_checkout_attempts
FROM total_checkout_attempts
GROUP BY action_date),
count_successful_checkout_attempts AS (
SELECT action_date,
       COUNT(*) AS count_successful_checkout_attempts
FROM successful_checkout_attempts 
GROUP BY action_date)
SELECT MONTH(t1.action_date) AS month,
       SUM(count_total_carts_created) AS count_total_carts_created,
       SUM(IFNULL(count_total_checkout_attempts, 0)) AS count_total_checkout_attempts,
       SUM(IFNULL(count_successful_checkout_attempts, 0)) AS count_successful_checkout_attempts,
	   SUM(IFNULL(count_successful_checkout_attempts, 0))/SUM(IFNULL(count_total_checkout_attempts, 0)) AS checkout_success_rate,
	   SUM(count_total_carts_created) - SUM(IFNULL(count_total_checkout_attempts, 0)) AS abandonment_carts,
       (SUM(count_total_carts_created) - SUM(IFNULL(count_total_checkout_attempts, 0)))/SUM(count_total_carts_created) AS abandonment_carts_rate
FROM  count_total_carts_created t1
LEFT JOIN count_total_checkout_attempts t2 ON t1.action_date = t2.action_date
LEFT JOIN count_successful_checkout_attempts t3 ON t1.action_date = t3.action_date
WHERE t1.action_date BETWEEN '2022-07-01' AND '2023-01-31'
GROUP BY MONTH(t1.action_date)
ORDER BY MONTH(t1.action_date);