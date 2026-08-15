#created by kamogelo Mogoba 

-- Generate predictions
-- i changed the CENTRIOD_ID to cluster_id for easier understanding.
---including the unique transaction_id so there are less chances of duplication each cluster maps to own row

-- I used merge instead of insert because it lets me handle both new and
-- existing transactions. If a transaction already exists but the data has
-- changed, it can be updated on the next run. If it's a new transaction,
-- it will simply be inserted.

-- This also helps with late arriving data, since any new or updated records
-- can be picked up in the next run without creating duplicates. It also
-- helps keep the query more efficient by avoiding unnecessary inserts.

-- This script is designed for one time processing of the data.
-- If scheduled, I would add a date range where clause so only the relevant partitions are scanned,
-- based on the known range of late-arriving data. This would save compute and runtime.
  --save from unnessary data being predicted 


MERGE `retail_gold.analytics_customer_segments` AS target
USING (
  SELECT
    t.transaction_id,
    t.customer_id,
    t.signup_date,
    t.purchase_date,
    t.amount,
    t.item_category,
    t.is_returned,
    t.days_to_first_purchase,
    CAST(p.CENTROID_ID AS INT64) AS cluster_id
  FROM
    ML.PREDICT(
      MODEL `retail_gold.customer_segmentation_model`,
      (
        SELECT transaction_id, amount, item_category 
        FROM `retail_silver.cleaned_transactions`
      )
    ) AS p
  INNER JOIN
    `retail_silver.cleaned_transactions` AS t
    ON p.transaction_id = t.transaction_id
) AS source
ON target.transaction_id = source.transaction_id

WHEN MATCHED THEN               
  UPDATE SET
    target.customer_id = source.customer_id,
    target.signup_date = source.signup_date,
    target.purchase_date = source.purchase_date,
    target.amount = source.amount,
    target.item_category = source.item_category,
    target.is_returned = source.is_returned,
    target.days_to_first_purchase = source.days_to_first_purchase,
    target.cluster_id = source.cluster_id

WHEN NOT MATCHED THEN
  INSERT (
    transaction_id,
    customer_id,
    signup_date,
    purchase_date,
    amount,
    item_category,
    is_returned,
    days_to_first_purchase,
    cluster_id
  )
  VALUES (
    source.transaction_id,
    source.customer_id,
    source.signup_date,
    source.purchase_date,
    source.amount,
    source.item_category,
    source.is_returned,
    source.days_to_first_purchase,
    source.cluster_id
  );
