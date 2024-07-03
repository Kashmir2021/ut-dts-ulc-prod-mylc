variable "labeltags" {
    description = ""
    type        = map(string)
    default     = {}
}

##############################################################################################################################
### Application
##############################################################################################################################

variable "service_name" {
  type        = string
  description = "The application name"
}
variable "service_description" {
  type        = string
  default     = ""
  description = "The application description"
}

##############################################################################################################################
### Instance
##############################################################################################################################

variable "eb_solution_stack_name" {
  type        = string
  default     = ""
  description = "The Elastic Beanstalk solution stack name"
}
variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "The EC2 instance type"
}
variable "instance_volume_type" {
  type        = string
  default     = "gp3"
  description = "Volume type (magnetic, general purpose SSD or provisioned IOPS SSD) to use for the root Amazon EBS volume attached to your environment's EC2 instances."
  # standard for magnetic storage
  # gp2 for general purpose SSD
  # io1 for provisioned IOPS SSD
}
variable "instance_volume_size" {
  type        = string
  default     = "10"
  description = "Storage capacity of the root Amazon EBS volume in whole GB. Required if you set RootVolumeType to provisioned IOPS SSD."
  # 10 to 16384 GB for general purpose and provisioned IOPS SSD.
  # 8 to 1024 GB for magnetic.
}
#variable "instance_volume_iops" {
#  type        = string
#  default     = "100"
#  description = "Desired input/output operations per second (IOPS) for a provisioned IOPS SSD root volume."
#  # The maximum ratio of IOPS to volume size is 30 to 1. For example, a volume with 3000 IOPS must be at least 100 GB.
#  # Value can be from 100 to 20000
#}
variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "The EC2 SSH KeyPair Name"
}
variable "min_instance" {
  type        = string
  default     = "1"
  description = "The minimum number of instances"
}
variable "max_instance" {
  type        = string
  default     = "1"
  description = "The maximum number of instances"
}
variable "deployment_policy" {
  type        = string
  default     = "Rolling"
  description = "The deployment policy"
}
variable "environment_type" {
  type        = string
  default     = "LoadBalanced"
  description = "Set to SingleInstance to launch one EC2 instance with no load balancer."
}
variable "port" {
  type        = string
  default     = "80"
  description = "The instance port"
}
variable "ssl_certificate_id" {
  type        = string
  default     = ""
  description = "ARN of an SSL certificate to bind to the listener."
}
variable "healthcheck_url" {
  type        = string
  default     = "/"
  description = "The path to which to send health check requests."
}
variable "healthcheck_response_code" {
  type        = string
  default     = "200"
  description = "The response code to expect for healthcheck url."
}
variable "ignore_healthcheck" {
  type        = string
  default     = "true"
  description = "Do not cancel a deployment due to failed health checks. (true | false)"
}
variable "healthreporting" {
  type        = string
  default     = "enhanced"
  description = "Health reporting system (basic or enhanced). Enhanced health reporting requires a service role and a version 2 platform configuration."
}

##############################################################################################################################
### Security
##############################################################################################################################

variable "vpc_id" {
  type        = string
  description = "The ID for your VPC."
}
variable "ec2_subnets" {
  type        = list
  description = "The IDs of the subnet/s for the ec2 beanstalk instance"
}
variable "elb_subnets" {
  type        = list
  description = "The IDs of the subnet or subnets for the elastic load balancer."
}
variable "security_groups" {
  type        = list(string)
  description = "Lists the Amazon EC2 security groups to assign to the EC2 instances in the Auto Scaling group in order to define firewall rules for the instances."
}
variable "elb_scheme" {
  type        = string
  default     = "internal"
  description = "Specify `internal` or 'public', 'internal' if you want to create an internal load balancer in your Amazon VPC so that your Elastic Beanstalk application cannot be accessed from outside your Amazon VPC"
}
variable "http_listener_enabled" {
  type        = bool
  default     = true
  description = "Enable port 80 (http)"
}
variable "http_listener_forwarded" {
  type        = bool
  default     = false
  description = "Enable port 80 (http) forwarding to port 443 (https)"
}
variable "loadbalancer_ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
  description = "Specify a security policy to apply to the listener. This option is only applicable to environments with an application load balancer"
}
variable "elb_security_groups" {
  type        = list(string)
  default     = []
  description = "Load balancer security groups"
}
variable "loadbalancer_managed_security_group" {
  type        = string
  default     = ""
  description = "Load balancer managed security group"
}
variable "elb_timeout" {
  type        = string
  default     = "60"
  description = "Load balancer connection timeout in seconds"
}
variable "tier_environment_type" {
  type        = string
  default     = "LoadBalanced"
  description = "Environment type, e.g. 'LoadBalanced' or 'SingleInstance'.  If setting to 'SingleInstance', `rolling_update_type` must be set to 'Time', `updating_min_in_service` must be set to 0, and `loadbalancer_subnets` will be unused (it applies to the ELB, which does not exist in SingleInstance environments)"
}
variable "tier" {
  type        = string
  default     = "WebServer"
  description = "Elastic Beanstalk Environment tier, 'WebServer' or 'Worker'"
}
variable "xms" {
  type        = string
  description = "Tomcat initial JVM heap sizes."
  default     = "256m"
}
variable "xmx" {
  type        = string
  description = "Tomcat maximum JVM heap sizes."
  default     = "512m"
}
