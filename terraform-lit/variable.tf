variable "vpc_cidr" {
    default = "10.20.0.0/16"
}

variable "vpc_cidr_mgmt" {
	default = "10.20.0.0/24"
}

variable "pub_cidr2a" {
	default = "10.20.1.0/24"
}

variable "pub_cidr2b" {
	default = "10.20.2.0/24"
}

variable "nlb_cidr2a" {
	default = "10.20.20.0/24"
}

variable "nlb_cidr2b" {
	default = "10.20.21.0/24"
}

variable "transworld" {
    default = ""
}

variable "stromfiber" {
    default = ""
}

variable "wateen" {
    default = ""
}

variable "rds_subnet1" {
	default = "10.20.10.0/24"
}
variable "rds_subnet2" {
	default = "10.20.11.0/24"
}