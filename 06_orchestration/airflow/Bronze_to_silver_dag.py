##SO my dag is going to take data from bronze table 
# and execute the silver transfformation table
#The dag is going be triggered when the table update once a day
##or when the bucket is updated with new data in that folder
##is going to include backfilling 

import sys
import os

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
sys.path.append('/home/airflow/gcs/data')
from Helper.bigquery import Bigquery
# In Cloud Composer, file paths should point to the DAG's folder structure or use absolute paths accessible by the worker
silver_sql_path = "/home/airflow/gcs/data/sql/silver_transform.sql"
gold_sql_path = "/home/airflow/gcs/data/sql/gold_prediction.sql"

def execute_silver_transformation():
  
    bigquery_load = Bigquery()

    #this get the file from the folder and executes the query using bigquery helper method
    client = bigquery_load.execute_query(silver_sql_path)

    return { "status": "success", "message": "Bronze to Silver transformation executed successfully."}

def execute_gold_predictions():
    bigquery_load = Bigquery()

    #this get the file from the folder and executes the query using bigquery helper method
    client = bigquery_load.execute_query(gold_sql_path)

    return { "status": "success", "message": "Gold predictions executed successfully."}
    

with DAG('Bronze_to_silver_dag',
         default_args={
             'owner': 'airflow',
             'depends_on_past': False,
             'email_on_failure': False,
             'email_on_retry': False,
             'retries': 1,
             'retry_delay': timedelta(minutes=5),
         },
         description='A DAG to execute data from silver trnasform sql and  to gold predictions sql',
         schedule_interval=timedelta(days=1),
         start_date=datetime(2026, 8, 13),
         catchup=True) as dag: # Enabled catchup for backfilling requirements


##add the dependencies between two task so that the one has to successfully excute before the other can execute
##first before the next one can execute.

# Instantiate tasks via PythonOperator
    silver_task = PythonOperator(
        task_id='execute_silver_transformation',
        python_callable=execute_silver_transformation,
    )

    gold_task = PythonOperator(
        task_id='execute_gold_predictions',
        python_callable=execute_gold_predictions,
    )

    # Set dependency: silver must complete before gold runs
    silver_task >> gold_task