# analytics-engineering-takehome

### Question1: Review Existing Unstructured Data and Diagram a New Structured Relational Data Model
![img.png](Q1%2Fimg.png)

### Question2: Write queries that directly answer predetermined questions from a business stakeholder
```postgresql
-- 1. What are the top 5 brands by receipts scanned for most recent month?

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
```

```postgresql
-- 2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

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
```

```postgresql
-- 3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT rewards_receipt_status, AVG(total_spent) AS average_spent
FROM receipts
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status;
```

```postgresql
-- 4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT r.rewards_receipt_status, SUM(i.quantity_purchased) AS total_items_purchased
FROM receipts r
         JOIN transactions t ON r._id = t.receipt_id
         JOIN items i ON t.barcode = i.barcode
WHERE r.rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY r.rewards_receipt_status;
```

```postgresql
-- 5. Which brand has the most spend among users who were created within the past 6 months?

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
```

```postgresql
-- 6. Which brand has the most transactions among users who were created within the past 6 months?

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

```

### Question3: Evaluate Data Quality Issues in the Data Provided
- Check out the EDA analysis on users, brands, receipts data. Manually EDA is done on each dataset also verified by AutoEDA tool. Check out directory Q3 for this question

### Question4: Communicate with Stakeholders
```text
**Subject**: Identifying and Addressing Data Quality Issues in Receipts, Users, and Brands Data

Hi Mike,

I hope this email finds you well. After a detailed exploratory analysis of our Receipts, Users, and Brands datasets, I've identified several critical data quality issues that I believe are essential to address:
1. **Missing Data**:
    * **finishedDate**: 49% of receipts lack the date indicating when they became invalid.
    * **pointsEarned**: 45% of records are missing data on points earned.
    * **purchasedItemCount**: Significant gaps in this data may affect the assessment of special offers and bonus points eligibility.
    * **totalSpent** : Missing values in these fields impact our ability to track transaction amounts and items purchased, which in turn affects the accuracy of pointsEarned data.
    * **topBrand**: Incomplete data on whether a brand should be featured as a 'top brand'.
    * **categoryCode**: Many records are missing the category code that references the brand's category.
2. **Anomalous Values**:
    * For pointsEarned, purchasedItemCount, and totalSpent, there are numerous entries with values significantly higher than the norm. These anomalies need investigation to ensure they are not the result of errors in our app processes.
3. **Duplicate Records:**
    * Over half of the records in the Users dataset are duplicates. This issue needs immediate attention to remove redundancies and prevent future occurrences.
4. **Inconsistent Date Formats:**
    * Dates are recorded in varying formats, deviating from standard formats like MM/DD/YYYY. We need to standardize date formats across our database.

**Questions About the Data:**
* What processes are currently in place for capturing and validating the data in these fields?
* Are there any known issues or events that could have led to the high number of missing or anomalous values?
* What steps have been taken previously to address similar data quality issues?

**Discovery of Data Quality Issues:**
* The issues were identified through a thorough exploratory data analysis, utilizing statistical summaries and visual inspections to highlight anomalies, missing values, and inconsistencies.
Information Needed to Resolve Issues:
* Detailed documentation on the data collection and processing workflows.
* Access to raw data logs and user activity records for further investigation.
* Input from the development team regarding the handling and storage of these data fields.

**Additional Information for Optimization:**
* Insights into user behavior and transaction patterns to better understand the context of the data.
* Historical data trends to identify persistent issues and their impact.
* Feedback from stakeholders on key metrics and priorities for data quality.

**Performance and Scaling Concerns:**
* Potential increased load on the database during data cleaning and validation processes.
* Ensuring real-time data updates do not compromise performance.
* Strategies to manage larger datasets effectively as we scale, such as indexing and partitioning.

I have developed a plan to address these issues and would like to discuss it with you in detail. Please let me know a convenient time for us to meet and go over the proposed solutions.

Best regards, 
Shiva
```
