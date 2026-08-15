-- #Train the K-Means model using 6 clusters, which I selected using the
-- elbow method shown in my notebook. The model is based on amount and
-- item_category only.


CREATE OR REPLACE MODEL retail_gold.customer_segmentation_model
OPTIONS(
    model_type = 'kmeans',
    num_clusters = 6,  ---6 clusters selected using the elbow method (SSE)
    standardize_features = TRUE
) AS 
SELECT 
    amount, 
    item_category
FROM retail_silver.cleaned_transactions;
