#created by Kamogelo Mogoba 
---schedule to run daily at 08:00
---reason I choose merg instead insert cause I do not duplicate  and can update changed rows if meet condition and late arriving data
---shorter runtime and if data is ammended, if can be update within the next run and for late arriving data inclusion



MERGE `project-5ef0b845-cbc9-4786-858.retail_silver.cleaned_transactions`  AS target

using (

select transaction_id,
customer_id,
date(COALESCE(signup_date, purchase_date)) AS signup_date,
date(purchase_date) as purchase_date,
 amount,
item_category, 
case when is_returned is Null then False else
is_returned end as is_returned,
--difference between signup_date and purchase_date
DATE_DIFF(DATE(purchase_date), DATE(signup_date), DAY)as days_to_first_purchase
from retail_bronze.raw_transactions
---write and reduce the rows that have amount let then 0
WHERE CAST(amount AS FLOAT64) > 0
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
