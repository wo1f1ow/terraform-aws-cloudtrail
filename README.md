# AWS CloudTrail Terraform Module

This Terraform module deploys an AWS CloudTrail with associated resources including an S3 bucket for log storage, KMS key for encryption, CloudWatch log group for log delivery, and optional SNS notifications.

## Features

- Creates a CloudTrail trail with customizable name and settings
- Sets up an S3 bucket for CloudTrail logs with optional versioning
- Configures KMS encryption for CloudTrail logs
- Sets up a CloudWatch log group for CloudTrail
- Supports optional SNS notifications for CloudTrail events
- Allows configuration of management events and data events
- Supports organization-wide trails
- Includes options for CloudTrail Insights
- Allows specifying an IAM role for decrypting CloudTrail logs

## Usage

```hcl
module "cloudtrail" {
  source  = "path/to/module"
  
  bucket_name     = "my-cloudtrail-bucket"
  cloudtrail_name = "my-cloudtrail"
  
  # Optional: Configure data events
  data_resources = [
    {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::my-important-bucket/"]
    }
  ]
  
  # Optional: Configure read/write type for events
  rw_type = "All"
  
  # Optional: Enable CloudTrail Insights
  insight_selector = [
    {
      insight_type = "ApiCallRateInsight"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | The name of the S3 bucket for CloudTrail logs | `string` | `""` | no |
| bucket_force_destroy | Whether to force destroy the S3 bucket | `bool` | `true` | no |
| cloudtrail_name | The name of the CloudTrail | `string` | `""` | no |
| include_global_service_events | Whether to include global service events | `bool` | `true` | no |
| is_multi_region_trail | Whether this is a multi-region trail | `bool` | `true` | no |
| enable_logging | Whether to enable logging | `bool` | `true` | no |
| log_retention_days | Number of days to retain logs in CloudWatch | `number` | `90` | no |
| create_sns_topic | Whether to create a new SNS topic for CloudTrail notifications | `bool` | `false` | no |
| sns_topic_name | The name of the SNS topic to create (if create_sns_topic is true) | `string` | `""` | no |
| existing_sns_topic_arn | The ARN of an existing SNS topic to use (if create_sns_topic is false) | `string` | `""` | no |
| enable_s3_bucket_versioning | Enable versioning on the S3 bucket | `bool` | `false` | no |
| decrypt_role_arn | ARN of the IAM role allowed to decrypt CloudTrail log files | `string` | `""` | no |
| include_management_events | Specifies whether to include management events | `bool` | `true` | no |
| data_resources | List of data resources to log events for | `list(object)` | `[]` | no |
| rw_type | Specifies whether to log read-only events, write-only events, or all events | `string` | `"All"` | no |
| insight_selector | List of insight types to enable | `list(object)` | `[]` | no |
| is_organization_trail | Specifies whether the trail is an AWS Organizations trail | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail_id | The name of the trail |
| cloudtrail_arn | The ARN of the trail |
| s3_bucket_id | The name of the S3 bucket |
| s3_bucket_arn | The ARN of the S3 bucket |
| kms_key_arn | The ARN of the KMS key |
| kms_key_id | The ID of the KMS key used for encrypting CloudTrail logs |
| cloudwatch_log_group_arn | The ARN of the CloudWatch log group |
| sns_topic_arn | The ARN of the SNS topic used for CloudTrail notifications |

## S3 Bucket Versioning

By default, S3 bucket versioning is disabled. Enable it by setting `enable_s3_bucket_versioning = true`.

## Organization Trails

Create an AWS Organizations trail by setting `is_organization_trail = true`. This can only be done in the organization's management account.

## Data Event Logging

Configure data event logging by providing a list of data resources:

```hcl
data_resources = [
  {
    type   = "AWS::S3::Object"
    values = ["arn:aws:s3:::my-bucket/"]
  },
  {
    type   = "AWS::Lambda::Function"
    values = ["arn:aws:lambda:us-east-1:123456789012:function:my-function"]
  }
]
```

## Event Read/Write Type

Control whether to log read-only events, write-only events, or all events using the `rw_type` variable:

```hcl
rw_type = "All"  # Can be "ReadOnly", "WriteOnly", or "All"
```

## CloudTrail Insights

Enable CloudTrail Insights by specifying insight types:

```hcl
insight_selector = [
  {
    insight_type = "ApiCallRateInsight"
  }
]
```

Note: Enabling data events or insights may increase your AWS costs.

## KMS Key for Log Encryption

This module creates a KMS key for encrypting CloudTrail logs. By default, only CloudTrail has permission to use this key for encryption. If you need to grant decryption permissions to a specific IAM role (e.g., for log analysis), you can use the `decrypt_role_arn` variable:

```hcl
module "cloudtrail" {
  source  = "path/to/module"
  
  # ... other configuration ...
  
  decrypt_role_arn = "arn:aws:iam::123456789012:role/CloudTrailDecryptRole"
}
```

This will add a policy statement to the KMS key allowing the specified role to decrypt CloudTrail log files. Ensure that the IAM role you specify has the necessary permissions to access the S3 bucket where the logs are stored.
