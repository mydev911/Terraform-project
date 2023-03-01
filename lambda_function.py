import boto3

def handler(event, context):
    s3 = boto3.client("s3")

    # Replace 'my-bucket' with the name of your S3 bucket
    bucket_name = 'my-bucket'
    
    # Get a list of all the objects in the bucket
    objects = s3.list_objects(Bucket=bucket_name)["Contents"]
    
    # Iterate over the list of objects and delete each one
    for obj in objects:
        s3.delete_object(Bucket=bucket_name, Key=obj["Key"])
