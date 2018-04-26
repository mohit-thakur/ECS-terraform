variable "vpc_id" {
    default = "vpc-c9a2caa1"
}
variable "ami_version" {
    default = "2017.09.k"
}
variable "ecs_cluster_name" {
    default = "default-ecs"
}

variable "docker_storage_size" {
    default = "50"
}
variable "key_name" {
    default = "test"
}
variable "appserver_sg" {
    default = "sg-f7c5cd9c"
}
variable "subnet_a" {
    default = "subnet-40fd9b28"
}
variable "subnet_b" {
    default = "subnet-ceada283"
}
variable "min_servers" {
    default = "1"
}
variable "max_servers" {
    default = "2"
}
variable "allowed_cidr_blocks" {
    default = "172.31.0.0/16"
}
variable "instance_type" {
    default = "t2.medium"
}
variable "infra_version" {
    default ="ecs"
}
variable "fr_hostname" {
  default ="default"
}
variable "fr_api_hostname" {
  default ="api-default"
}
variable "frontend_desired_count" {
  default ="1"
}
variable "dockerhub_email" {
  default = ""
}
variable "dockerhub_token" {
  default = ""
}
