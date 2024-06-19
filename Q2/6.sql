-- Which brand has the most transactions among users who were created within the past 6 months?

WITH RecentUsers AS (
    SELECT _id
    FROM users
    WHERE created_date >= CURRENT_DATE - INTERVAL '6 months'
)
SELECT b.name, COUNT(t.receipt_id) AS transaction_count
FROM transactions t
         JOIN items i ON t.barcode = i.barcode
         JOIN brands b ON i.brand_id = b._id
         JOIN receipts r ON t.receipt_id = r._id
WHERE r.user_id IN (SELECT _id FROM RecentUsers)
GROUP BY b.name
ORDER BY transaction_count DESC
LIMIT 1;
