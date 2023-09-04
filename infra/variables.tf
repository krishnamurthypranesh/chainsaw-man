# aws provider variables
variable "aws_region" {
    type = string
}

variable "ecr_repo_url" {
    type = string
}

# newrelic provider variables
variable "new_relic_account_id" {
    type = string
}

variable "new_relic_api_key" {
    type = string
}

variable "new_relic_region" {
    type = string
}
