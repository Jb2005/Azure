
variable "location" {
  description = "default location"
  type        = string
  default = "eastus2"
}

variable "tags" {
  type = map

  default = {
    Environment = "dev"
  }
}