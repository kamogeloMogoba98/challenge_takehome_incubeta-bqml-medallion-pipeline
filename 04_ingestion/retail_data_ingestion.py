import pandas as pd 
from Helper.logger import setup_logger
from Helper.bigquery import Bigquery
from google.cloud import storage
from datetime import datetime


date_str = datetime.now().strftime("%Y-%m-%d")
timestamp_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
bucket_name = "project-5ef0b845-cbc9-4786-858-raw-data-lake"  # Replace with your actual bucket name
bigquery_load=Bigquery()
storage_client = storage.Client()
client = bigquery_load.connect()




csv_file_path = "/home/HP/retail_folder/raw_csv_folder/raw_transactions.csv"

df =pd.read_csv(csv_file_path)

print(df.head(10))



existing_ids_query = """
    SELECT DISTINCT transaction_id 
    FROM `retail_bronze.raw_transactions`
"""


#load to dataframe and makes the dataframe a python set so we can compare
existing_ids_df = client.query(existing_ids_query).to_dataframe()
existing_ids = set(existing_ids_df['transaction_id'])
    
   
df_new = df[~df['transaction_id'].isin(existing_ids)]


#inserts the datafram to table even if it does not exist
if not df_new.empty:
    bigquery_load.load_to_bigquery(
        dataframe=df_new,
        table_name="retail_bronze.raw_transactions",
        chunksize=100000,
        if_exists="append",
    ) 

    print("Dataframe loaded to BigQuery successfully.")


    #send data to the file as parquet to a google cloud storage bucket
    #preferably that has date folder and timestamp sub folder to avoid overwriting the data
    #I saved it as a parquet file to reduce the size of the data and also to make it easier to read and write the data


  
    bucket = storage_client.bucket(f"{bucket_name}")
    blob = bucket.blob(f"{date_str}/{timestamp_str}/raw_transactions.parquet")
    blob.upload_from_filename(f'{csv_file_path}')

print(f"Total rows fetched: {len(df)}. New unique rows to insert: {len(df_new)}")
if len(df_new)==0:
    print("No new unique rows to insert. Dataframe is empty.")




