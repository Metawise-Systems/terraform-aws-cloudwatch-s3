variable "cloudwatch_name" {
  description = ""
  type        = string
  default     = "metawise-demo"
}

variable "log_bucket" {
  description = ""
  type        = string
  default     = "metawise-demo-bucket"
}

variable "log_name" {
  description = ""
  type        = string
  default     = "metawise-demo-log"
}

variable "log_stream" {
  description = "A log stream to watch"
  type        = string
  default     = "not-necessary"
}

variable "filter_pattern" {
  type        = string
  description = "description"
  default     = ""
}

variable "region_desc" {
  description = "Region"
  type        = string
  default     = "eu-west-1"
}

variable "log_group_name" {
  default     = "metawise-demo-log"
  description = "A default log group name"
  type        = string
}

variable "common_tags" {
  type        = map(any)
  description = "Implements the common tags scheme"
  default = {
    "project" = "demo-metawise"
  }
}

variable "sse_algorithm" {
  type        = string
  description = "encryption algorithm to use"
  default     = "aws:kms"
}

variable "kms_master_key_id" {
  type        = string
  description = "kms key id"
  default     = "aws/s3"
}
