#created by Kamogelo Mogoba 
---Schedule to run daily at 08:00
 --UPPER(TRIM(item_category)) --makes sure values come in one standardized way SPORTS instead if Sports or sports 
-- Reason for choosing merge instead of insert
-- Merge prevents duplicate records and allows changed rows to be updated
-- when they meet the required conditions. It also supports late arriving data.
-- Benefits: shorter runtime, updates amended data during the next run,
-- and includes late arriving data.
 -- This script is designed for one time processing of the data.
-- If scheduled, I would add a date range so only the relevant partitions are scanned and also a processed_at(timestamp) column to know when each batched data arrived ,
-- based on the known range of late-arriving data. This would save compute and runtime.



MERGE `project-5ef0b845-cbc9-4786-858.retail_silver.cleaned_transactions`  AS target

using (
select transaction_id,
customer_id,
date(COALESCE(signup_date, purchase_date)) AS signup_date,
date(purchase_date) as purchase_date,
 amount,
 UPPER(TRIM(item_category)) AS item_category, --standardized records
case when is_returned is Null then False else
is_returned end as is_returned,
--difference between signup_date and purchase_date taking into consideration the coalesce function
DATE_DIFF(DATE(purchase_date), Date(COALESCE(signup_date, purchase_date)), DAY)as days_to_first_purchase
from retail_bronze.raw_transactions
---write and reduce the rows that have amount let then 0
WHERE CAST(amount AS FLOAT64) > 0 and DATE(purchase_date) >= DATE(COALESCE(signup_date, purchase_date))---so that only records where purchase date are bigger the signup_date 
group by 1,2,3,4 ,5,6,7,8
)AS source
ON target.transaction_id = source.transaction_id

----if macthed, update these records if the OR records changed values

WHEN MATCHED AND (
    target.customer_id != source.customer_id OR
    target.amount != source.amount OR
    target.item_category != source.item_category OR
    target.is_returned != source.is_returned
) THEN
    UPDATE SET 
        customer_id = source.customer_id,
        signup_date = source.signup_date,
        purchase_date = source.purchase_date,
        amount = source.amount,
        item_category = source.item_category,
        is_returned = source.is_returned,
        days_to_first_purchase = source.days_to_first_purchase

---- insert new records if there is no match----final
WHEN NOT MATCHED THEN
    INSERT (
        transaction_id,
        customer_id,
        signup_date,
        purchase_date,
        amount,
        item_category,
        is_returned,
        days_to_first_purchase
    )
    VALUES (
        source.transaction_id,
        source.customer_id,
        source.signup_date,
        source.purchase_date,
        source.amount,
        source.item_category,
        source.is_returned,
        source.days_to_first_purchase
    );
