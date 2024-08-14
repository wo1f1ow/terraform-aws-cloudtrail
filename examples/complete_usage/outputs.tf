output "cloudtrail_arn" {
  value = module.cloudtrail.cloudtrail_arn
}

output "s3_bucket_name" {
  value = module.cloudtrail.s3_bucket_id
}

output "sns_topic_arn" {
  value = module.cloudtrail.sns_topic_arn
}