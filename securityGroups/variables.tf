variable "labeltags" {
    description = ""
    type        = map(string)
    default     = {}
}

variable "subnetPrivateACidr" {
    type        = string
    default     = ""
}
variable "subnetPrivateBCidr" {
    type        = string
    default     = ""
}
variable "subnetPublicACidr" {
    type        = string
    default     = ""
}
variable "subnetPublicBCidr" {
    type        = string
    default     = ""
}

variable "vpcId" {
    type = string
    default = ""
}
