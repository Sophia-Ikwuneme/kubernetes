variable "ssh_port" {
  default = "22"
}

variable "port_8080" {
  default = "8080"
}
# CIDR for all traffic
variable "all_cidr" {
  default = ["0.0.0.0/0"]
}
