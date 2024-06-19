-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

WITH RecentMonth AS (
    SELECT b.name, COUNT(r._id) AS receipt_count
    FROM receipts r
             JOIN transactions t ON r._id = t.receipt_id
             JOIN items i ON t.barcode = i.barcode
             JOIN brands b ON i.brand_id = b._id
    WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY b.name
    ORDER BY receipt_count DESC
    LIMIT 5
),
     PreviousMonth AS (
         SELECT b.name, COUNT(r._id) AS receipt_count
         FROM receipts r
                  JOIN transactions t ON r._id = t.receipt_id
                  JOIN items i ON t.barcode = i.barcode
                  JOIN brands b ON i.brand_id = b._id
         WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 months')
         GROUP BY b.name
         ORDER BY receipt_count DESC
         LIMIT 5
     )
SELECT rm.name AS recent_month_brand, rm.receipt_count AS recent_month_count,
       pm.name AS previous_month_brand, pm.receipt_count AS previous_month_count
FROM RecentMonth rm
         FULL OUTER JOIN PreviousMonth pm ON rm.name = pm.name
ORDER BY rm.receipt_count DESC NULLS LAST, pm.receipt_count DESC NULLS LAST;
