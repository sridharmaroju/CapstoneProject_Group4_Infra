# tflint-ignore: terraform_unused_declarations
variable "cards_table_name" {
  type        = string
  default     = "cards"
  description = "Table Name for Cards"
}

# tflint-ignore: terraform_unused_declarations
variable "name_prefix" {
  type        = string
  default     = "ce11-capstone-group4"
  description = "Prefix for Resources"
}

# tflint-ignore: terraform_unused_declarations
variable "dev_callback_url" {
  type        = string
  default     = "http://localhost:4200/callback"
  description = "Development App Callback URL"
}

# tflint-ignore: terraform_unused_declarations
variable "prod_callback_url" {
  type        = string
  default     = "https://yourdomain.com/callback"
  description = "Production App Callback URL"
}

# tflint-ignore: terraform_unused_declarations
variable "dev_logout_url" {
  type        = string
  default     = "http://localhost:4200/logout"
  description = "Development App Logout URL"
}

# tflint-ignore: terraform_unused_declarations
variable "prod_logout_url" {
  type        = string
  default     = "https://yourdomain.com/logout"
  description = "Production App Logout URL"
}

# tflint-ignore: terraform_unused_declarations
variable "cognito_auth_domain" {
  type        = string
  default     = "ce11-capstone-group4"
  description = "Cognito Auth Domain"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region"
}

# tflint-ignore: terraform_unused_declarations
variable "domain" {
  type        = string
  description = "Domain used for Capstone Project"
  default     = "sctp-sandbox.com"
}

# tflint-ignore: terraform_unused_declarations
variable "bucket_name" {
  type        = string
  description = "Bucket for hosting the Web App Frontend"
  default     = "frontendwebapp"
}

# tflint-ignore: terraform_unused_declarations
variable "allowed_origin" {
  type        = string
  description = "Frontend origin allowed to access API"
}

# tflint-ignore: terraform_unused_declarations
variable "azs" {
  description = "List of Availability Zones for the VPC"
  type        = list(string)
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "ce11capstonegroup4AppDB"
}

variable "db_instance_name" {
  type    = string
  default = "db-instance"
}