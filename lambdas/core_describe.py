import boto3
rname = 'eu-west-1'

def lambda_handler(event, context):
	ec2 = boto3.client('ec2', rname)
	instance_ids = {}
	count = 0

    def fetch_instances():
        try:
        	if event['params']['querystring']['state'] is None:
        		full_json = ec2.describe_instances()
    		    return full_json
        	else:
        		state_query = event['params']['querystring']['state']
        		full_json = ec2.describe_instances(
	    			Filters=[
        				{
            				'Name': 'instance-state-name',
            				'Values': [
                				state_query,
            				]
        				},
    			])
    		    return full_json

	body_json = fetch_instances()
	for item in body_json['Reservations']:
	    for instance in item['Instances']:
	        instance_ids['instance_id' + "_" + str(count)] = instance['InstanceId']
	        count += 1
	return instance_ids