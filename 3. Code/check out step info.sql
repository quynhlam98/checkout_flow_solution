-- category action_name
SELECT DISTINCT action_name FROM checkout_database.checkout_actions;

-- total_carts_created
SELECT *
FROM checkout_carts;

-- total_checkout_attempts: users who have purchase in cart
SELECT tc.user_id,
       a.action_name,
       a.action_date
FROM checkout_carts as tc
LEFT JOIN checkout_actions AS a 
ON a.user_id = tc.user_id
WHERE a.action_name LIKE '%checkout%'
AND a.action_date BETWEEN '2022-07-01' AND '2023-01-31';

-- total_successful_attempts
SELECT total_checkout_attempts.user_id,
       total_checkout_attempts.action_name,
       total_checkout_attempts.action_date
FROM (SELECT tc.user_id,
       a.action_name,
       a.action_date
FROM checkout_carts as tc
LEFT JOIN checkout_actions AS a 
ON a.user_id = tc.user_id
WHERE a.action_name LIKE '%checkout%'
AND a.action_date BETWEEN '2022-07-01' AND '2023-01-31') as total_checkout_attempts
WHERE total_checkout_attempts.action_name LIKE '%success%'
GROUP BY total_checkout_attempts.user_id; -- unnecessary

-- count_total_carts (daily)
SELECT action_date,
       COUNT(*) as count_total_carts
FROM checkout_carts
GROUP BY action_date;

-- count_total_checkout_attempts (daily)
SELECT action_date,
       COUNT(*) as count_total_checkout_attempts
FROM (SELECT tc.user_id,
       a.action_name,
       a.action_date
FROM checkout_carts as tc
LEFT JOIN checkout_actions AS a 
ON a.user_id = tc.user_id
WHERE a.action_name LIKE '%checkout%'
AND a.action_date BETWEEN '2022-07-01' AND '2023-01-31') AS total_checkout_attempts
GROUP BY action_date;

-- count_successful_checkout_attempts(daily)
SELECT action_date,
       COUNT(*) as count_successful_checkout_attempts
FROM (SELECT total_checkout_attempts.user_id,
       total_checkout_attempts.action_name,
       total_checkout_attempts.action_date
FROM (SELECT tc.user_id,
       a.action_name,
       a.action_date
FROM checkout_carts as tc
LEFT JOIN checkout_actions AS a 
ON a.user_id = tc.user_id
WHERE a.action_name LIKE '%checkout%'
AND a.action_date BETWEEN '2022-07-01' AND '2023-01-31') as total_checkout_attempts
WHERE total_checkout_attempts.action_name LIKE '%success%') AS successful_checkout_attempts
GROUP BY action_date;

-- checkout step 
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
SELECT t1.action_date,
       count_total_carts_created,
       IFNULL(count_total_checkout_attempts, 0) AS count_total_checkout_attempts,
       IFNULL(count_successful_checkout_attempts, 0) AS count_successful_checkout_attempts
FROM  count_total_carts_created t1
LEFT JOIN count_total_checkout_attempts t2 ON t1.action_date = t2.action_date
LEFT JOIN count_successful_checkout_attempts t3 ON t1.action_date = t3.action_date
WHERE t1.action_date BETWEEN '2022-07-01' AND '2023-01-31'
ORDER BY t1.action_date;
       



