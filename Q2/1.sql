-- What are the top 5 brands by receipts scanned for most recent month?

WITH RecentMonthReceipts AS (
    SELECT r._id, ri.barcode
    FROM receipts r
             JOIN transactions t ON r._id = t.receipt_id
             JOIN items ri ON t.barcode = ri.barcode
    WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
)
SELECT b.name, COUNT(r._id) AS receipt_count
FROM RecentMonthReceipts r
         JOIN items i ON r.barcode = i.barcode
         JOIN brands b ON i.brand_id = b._id
GROUP BY b.name
ORDER BY receipt_count DESC
    LIMIT 5;
