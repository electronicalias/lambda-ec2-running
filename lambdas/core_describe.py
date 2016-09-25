import boto3
rname = 'eu-west-1'

def lambda_handler(event, context):
	ec2 = boto3.client('ec2', rname)
	instance_ids = {}
	count = 0
	body_json = ec2.describe_instances()
	for item in body_json['Reservations']:
	    for instance in item['Instances']:
	        instance_ids['instance_id' + "_" + str(count)] = instance['InstanceId']
	        count += 1
	return instance_ids