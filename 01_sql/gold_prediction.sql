

-- Generate predictions 
-- i changed the CENTRIOD_ID to cluster_id for easier understanding
---including the unique transaction_id so there are less chances of duplication each cluster maps to own row



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
