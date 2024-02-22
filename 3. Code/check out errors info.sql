WITH check_out_errors_info AS (
SELECT
    user_id, action_date, action_name, error_message, device
FROM
    checkout_actions
WHERE action_date BETWEEN '2022-07-01' and '2023-01-31' and action_name like '%checkout%'
GROUP BY user_id
ORDER BY action_date)
SELECT error_message,
	   SUM(CASE WHEN device = 'desktop' THEN 1 ELSE 0 END) AS total_errors_on_desktop,
       SUM(CASE WHEN device = 'mobile' THEN 1 ELSE 0 END) AS total_errors_on_mobile,
       COUNT(*) AS total_errors,
       SUM(CASE WHEN device = 'desktop' THEN 1 ELSE 0 END)/COUNT(*) AS errors_on_desktop_rate,
       SUM(CASE WHEN device = 'mobile' THEN 1 ELSE 0 END)/COUNT(*) AS errors_on_mobile_rate
FROM check_out_errors_info 
GROUP BY error_message
ORDER BY total_errors DESC;
