-- Which brand has the most spend among users who were created within the past 6 months?

WITH RecentUsers AS (
    SELECT _id
    FROM users
    WHERE created_date >= CURRENT_DATE - INTERVAL '6 months'
)
SELECT b.name, SUM(r.total_spent) AS total_spent
FROM receipts r
         JOIN transactions t ON r._id = t.receipt_id
         JOIN items i ON t.barcode = i.barcode
         JOIN brands b ON i.brand_id = b._id
WHERE r.user_id IN (SELECT _id FROM RecentUsers)
GROUP BY b.name
ORDER BY total_spent DESC
LIMIT 1;
