# terraform-aws-example-project
My pet project during learning of Terraform with AWS as provider

In order to run infrastructure you have to provide AWS creds:

- export AWS_ACCESS_KEY_ID=your_aws_access_key
- export AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key

Also you need to create S3 bucket `terraform-example-project-state` or you can update main.tf file with your `bucket_name`

Then go to to /example-project/dev (development infrastructure)

and run the following commands:

- terraform init
- terraform plan (optional
- terraform apply
