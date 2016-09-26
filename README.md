# lambda-ec2-running

![alt text](https://cloud.githubusercontent.com/assets/3788860/18849849/c883b3b2-842c-11e6-80b0-bf0aaf6384a8.png)

The first iteration of this returns all the instances running in the specified region and account. This is meant to be used with CircleCI and will provision an API Gateway (with no authentication), a Lambda Function that queries EC2 Instances and uses Terraform to acheive this.

## Usage

1. Create a CircleCI Account
2. Attach and Authenticate a new Project to your BitBucket or GitHub Repository that contains this code
3. The project will try and build, but this will fail because you need to give it some Environment Variables
4. Configure the project with the following environment variables

  BUCKET_NAME = [whatever bucket you want to use in the same region for storing config]
  RUN_REGION = [whatever region you want to configure this for]
  ACCOUNT_ID = [the numeric id of the account where you are running this]
  
5. On the project navigate to the segment for Permissions and set the AWS Permissions

As it stands, the environment is provisioned and immediately torn down, as this is purely for testing purposes for me while I learn to use API Gateway/Lambda. CircleCI happened to be the slickest way to configure this without having to use ANY servers such as Jenkins.

To make it work, carry out the 6th step;

6. Hash the lines that read as follows:
`- ./terraform plan -var 'account_id="$ACCOUNT_ID"' -var "run_region=$RUN_REGION" -var-file="variables.tf" -out="$(if [[ "$CIRCLE_BRANCH" != "master" ]]; then echo "develop"; else echo "master"; fi)/terraform_destroy.plan" -destroy`
`- ./terraform destroy -var 'account_id="$ACCOUNT_ID"' -var "run_region=$RUN_REGION" -force`

They should now look like this:
`#- ./terraform plan -var 'account_id="$ACCOUNT_ID"' -var "run_region=$RUN_REGION" -var-file="variables.tf" -out="$(if [[ "$CIRCLE_BRANCH" != "master" ]]; then echo "develop"; else echo "master"; fi)/terraform_destroy.plan" -destroy`
`#- ./terraform destroy -var 'account_id="$ACCOUNT_ID"' -var "run_region=$RUN_REGION" -force`

I'm going to try and add more features to this, just for my own knowledge, they would be the following:

https://longurl/production/instances/..
../running
../terminated
../stopped
../search?tag=something

^^ I'm not sure the last one is possible, but I have high hopes!

Enjoy!
