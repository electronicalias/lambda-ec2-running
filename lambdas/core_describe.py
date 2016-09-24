import boto3
rname = 'eu-west-1'

def lambda_handler(event, context):
	ec2 = boto3.client('ec2', rname)
	data = ec2.describe_instances()
	for item in data['Reservations']:
	    for instance in item['Instances']:
	        print instance['InstanceId']