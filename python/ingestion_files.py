import functions_framework
import pandas as pd
from google.cloud import bigquery
from google.cloud import storage
import os
from datetime import datetime

TABLE_MAPPING = {
    "accounts": "accounts",
    "city": "city",
    "country": "country",
    "customers": "customers",
    "d_month": "d_month",
    "d_time": "d_time",
    "d_week": "d_week",
    "d_weekday": "d_weekday",
    "d_year": "d_year",
    "pix_movements": "pix_movements",
    "state": "state",
    "transfer_ins": "transfer_ins",
    "transfer_outs": "transfer_outs"
}

class CSVToBigQuery:
    def __init__(self, bucket_name, dataset_id, project_id, table_name):
        self.bucket_name = bucket_name
        self.dataset_id = dataset_id
        self.project_id = project_id
        self.table_name = table_name
        self.client = bigquery.Client()
        self.storage_client = storage.Client()

    def process_file(self, file_name):
        self.load_csv_to_bigquery(file_name)
        FileMover(self.bucket_name, "nubank-processed-files").move_file(file_name)
        return f"File {file_name} processed and moved successfully."

    def load_csv_to_bigquery(self, file_name):
        bucket = self.storage_client.bucket(self.bucket_name)
        blob = bucket.blob(file_name)
        temp_path = f"/tmp/{file_name}"
        blob.download_to_filename(temp_path)
        
        df = pd.read_csv(temp_path, dtype=str)  # Converte todas as colunas para string
        table_id = f"{self.project_id}.{self.dataset_id}.{self.table_name}"
        
        job_config = bigquery.LoadJobConfig(
            autodetect=True,
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND
        )
        
        job = self.client.load_table_from_dataframe(df, table_id, job_config=job_config)
        job.result()
        print(f"File {file_name} successfully loaded into {table_id}")

class FileMover:
    def __init__(self, source_bucket, destination_bucket):
        self.storage_client = storage.Client()
        self.source_bucket = self.storage_client.bucket(source_bucket)
        self.destination_bucket = self.storage_client.bucket(destination_bucket)
    
    def move_file(self, file_name):
        today_date = datetime.utcnow().strftime('%Y%m%d')
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        folder_path = f"{today_date}/"
        new_file_name = f"{folder_path}{os.path.splitext(file_name)[0]}_{timestamp}{os.path.splitext(file_name)[1]}"
        source_blob = self.source_bucket.blob(file_name)
        destination_blob = self.destination_bucket.blob(new_file_name)
        self.destination_bucket.copy_blob(source_blob, self.destination_bucket, new_file_name)
        source_blob.delete()
        print(f"File {file_name} moved to {self.destination_bucket.name}/{folder_path} as {new_file_name}")

# Cloud Function trigger
@functions_framework.cloud_event
def ingestion_files_csv(cloud_event):
    data = cloud_event.data
    file_name = data["name"]
    bucket_name = data["bucket"]
    
    base_name = os.path.splitext(file_name)[0]  # Remove a extensão do arquivo
    table_name = TABLE_MAPPING.get(base_name, "unknown_table")
    
    if table_name == "unknown_table":
        print(f"Warning: No matching table found for file {file_name}")
        return f"No matching table found for file {file_name}"
    
    processor = CSVToBigQuery(bucket_name, "bronze", "nubank-case-453405", table_name)
    result = processor.process_file(file_name)
    return result
