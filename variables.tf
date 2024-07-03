variable "privateSubnetA" {
  type    = string
  default = "subnet-02aeab62455ed0952"
}

variable "privateSubnetB" {
  type    = string
  default = "subnet-0fd6857528d5f6a7a"
}

variable "publicSubnetA" {
  type    = string
  default = "subnet-020197cfc4e460e13"
}

variable "publicSubnetB" {
  type    = string
  default = "subnet-0698ba8a33f03708f"
}

variable "vpcId" {
  type    = string
  default = "vpc-0aa48fdb6dd32a030"
}

variable "env" {
  type    = string
  default = "prod"
}

#variable "at_utah_gov_cert"
variable "utah_gov_cert" {
  type    = string
  default = "arn:aws:acm:us-west-2:182497516148:certificate/24492263-1cd8-4a29-b071-9e63c7622ab4"
}



#variable "github_env_variables" {
#  type        = list(map(string))
#  description = "list of objects"
#  default = [
#    {
#      "name": "RUNNER_SCOPE",
#      "value": "org"
#    },
#    {
#      "name": "ORG_NAME",
#      "value": "utahdts"
#    },
#    {
#      "name": "LABELS",
#      "value": "csd"
#    },
#    {
#      "name": "RUNNER_GROUP",
#      "value": "doc"
#    },
#    {
#      "name": "DISABLE_AUTO_UPDATE",
#      "value": "1"
#    },
#    {
#      "name": "EPHEMERAL",
#      "value": "1"
#    }
#  ]
#}
