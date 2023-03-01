variable "vpc_cidr" {
    type = string
    description = "my CIDR block"
    sensitive = false
}

variable "tags" {
    type = map(string)
    description = "(optional) describe your variable"
}

variable "subnet1_cidr_block" {
    type = string
    description = "subnet cidr"
}

variable "destination_cidr_block" {
    type = string
    description = "destination_cidr_block"
}

variable "instance_type" {
    type = string
    description = "instance_type"
}
