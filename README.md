# aws-lambda-unzip

**Unzip function for AWS Lambda**

The function extracts zip files and uploads files to the same S3 location. It should be waiting for S3 upload event.

## Permissions

You need to give following permissions:

	{
	    "Effect": "Allow",
	    "Action": [
	        "s3:GetObject",
	        "s3:PutObject",
	        "s3:DeleteObject"
	    ],
	    "Resource": [
	        "arn:aws:s3:::target-bucket"
	    ]
	}

## Requirements

- Python 3.6

## License

See [LICENSE](LICENSE)

## Configuring AWS Lambda via Terraform script

In order to automatically configure lambda, check `terraform.tfvars` and run the following command:

```bash
zip unzip_lambda.zip -xi unzip_lambda.py
terraform apply
```
