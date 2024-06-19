-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT r.rewards_receipt_status, SUM(i.quantity_purchased) AS total_items_purchased
FROM receipts r
         JOIN transactions t ON r._id = t.receipt_id
         JOIN items i ON t.barcode = i.barcode
WHERE r.rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY r.rewards_receipt_status;
