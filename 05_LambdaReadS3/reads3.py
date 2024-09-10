import json
import boto3
import csv
import io
import os

def lambda_handler(event, context):
    bucket_name = "jk-tf-bucket-lambda-read"
    if not bucket_name:
        return {
            'statusCode': 500,
            'body': json.dumps('BUCKET_NAME environment variable not set')
        }
    
    object_key = event['Records'][0]['s3']['object']['key']
    s3_client = boto3.client('s3')

    try:
        response = s3_client.get_object(Bucket = bucket_name, Key = object_key)
        csv_content = response['Body'].read().decode('utf-8')

        csv_reader = csv.reader(io.StringIO(csv_content))
        for row in csv_reader:
            print(row)
        return {
        'statusCode': 200,
        'body': json.dumps('CSV file read successfully!')
        }

    except Exception as e:
        print(f"Error reading object {object_key} from bucket {bucket_name}.")
        print(e)
        raise e
        
