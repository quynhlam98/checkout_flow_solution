WITH type_of_purchase_table AS(
 SELECT (CASE WHEN action_name LIKE '%lifetime%' THEN 'lifetime package'
			WHEN action_name LIKE '%annual%' THEN  'annual package'
			WHEN action_name LIKE '%quarterly%' THEN 'quarterly package'
			WHEN action_name LIKE '%monthly%' THEN 'monthly package'
            ELSE 'single course' END) AS type_of_purchase
FROM checkout_actions
WHERE action_name LIKE '%checkout%')
SELECT type_of_purchase,
       COUNT(*)
FROM type_of_purchase_table
GROUP BY type_of_purchase;
       