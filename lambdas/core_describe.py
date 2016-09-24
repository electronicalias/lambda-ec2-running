import boto3
rname = 'eu-west-1'

def lambda_handler(event, context):
	ec2 = boto3.client('ec2', rname)
	print(ec2.describe_instances())