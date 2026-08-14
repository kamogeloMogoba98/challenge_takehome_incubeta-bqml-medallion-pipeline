import os
from google.cloud import bigquery
from pandas_gbq import to_gbq
import pandas_gbq


class Connect:
    """
    Connect class is here to allow the code to be extensible, i.e., we can easily add another DB Connector.
    """

    def __init__(self):
        self.connection = None
        self.project_id = None

class Bigquery(Connect):
    """
    This class is for wrapping some DB operations in Python.
    """

    def __init__(self):
        Connect.__init__(self)
        self.project_id = os.getenv("PROJECT_ID")

    def connect(self):
        """This function will return the Bigquery connect object"""
        try:
    
            bigquery_client = bigquery.Client()
            return bigquery_client

        except Exception as exception:
            raise Exception(f"Could not Connect to Bigquery!!! \n{exception}")

    def open_file(self, file_name):
        """
        This will open a .sql file and return it as a string/text.
        """
        try:
            sql_file = os.path.realpath(file_name)
            with open(sql_file, "r", encoding="utf-8") as sql_file:
                sql_query = sql_file.read()
            return sql_query

        except Exception as exception:
            raise Exception(f"Could not open the file!!! \n{exception}")

    def execute_query(self, query_file_path):
        try:
            # Your existing code to execute the BigQuery query
            response = self.execute_bigquery_query(query_file_path)
            dataframe = response.to_dataframe()
            # Further processing of the dataframe...

        except google.api_core.exceptions.BadRequest as bq_err:
            print(f"BigQuery BadRequest Error: {bq_err}")
            # Handle the BigQuery BadRequest error, e.g., log the error or notify someone
            raise  # Optionally, re-raise the exception to terminate the script with an error

        except Exception as exception:
            print(f"Error Executing the Query!!! \n{exception}")
            # Handle other exceptions as needed
            raise  # Optionally, re-raise the exception to terminate the script with an error

    def execute_bigquery_query(self, query_file_path):
        # Your code to execute the BigQuery query and return the response
        pass

    def execute_query(self, file_name=None, sql=None):
        """
        Execute SQL Queries against BQ
        """
        try:
            
            if file_name is None and sql is None:
                raise Exception("Invalid file or SQL query was not passed")

            if file_name is not None and sql is not None:
                raise Exception("Cannot use both query at the same time!!!")

            self.connection = self.connect()
            bigquery_client = self.connection

            sql_query = sql
            if file_name is not None:
                sql_query = self.open_file(file_name=file_name)

            # Execute Query
            response = bigquery_client.query(sql_query)
            dataframe = response.to_dataframe()

            return dataframe

        except Exception as exception:
            raise Exception(f"Error Executing the Query!!! \n{exception}")

        finally:
            self.connection.close()

    def load_to_bigquery(self, dataframe, table_name, chunksize=100000, if_exists='append'):
        """
        This method can be used to ingest a dataframe to Bigquery.
        """
        project_id = self.project_id
        to_gbq(dataframe, table_name, project_id, chunksize=chunksize, if_exists=if_exists)

    def load_dataframe(self, dataframe, table_id, project_id):
        pandas_gbq.to_gbq(dataframe, table_id, project_id)

