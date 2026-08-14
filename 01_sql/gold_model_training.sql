----#Train the K-Means model using 6 clusters which I found using the elbow method that is in
---- my Notebook based strictly on amount and item_category
CREATE OR REPLACE MODEL retail_gold.customer_segmentation_model
OPTIONS(
    model_type = 'kmeans',
    num_clusters = 6,  #elbow method from Sum of squared Error
    standardize_features = TRUE
) AS 
SELECT 
    amount, 
    item_category
FROM retail_silver.cleaned_transactions;