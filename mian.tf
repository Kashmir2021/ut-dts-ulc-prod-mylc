
data "aws_vpc" "mainVPC" {
  id = var.vpcId
}
data "aws_subnet" "privateA" {
  id = var.privateSubnetA
}
data "aws_subnet" "privateB" {
  id = var.privateSubnetB
}
data "aws_subnet" "publicA" {
  id = var.publicSubnetA
}
data "aws_subnet" "publicB" {
  id = var.publicSubnetB
}


#resource "aws_iam_policy" "read-write-delete-s3-storage" {
#  name = "read-write-delete-s3-storage"
#  description = "Allows read and write access to s3 bucket"
#
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Effect = "Allow",
#      Action = [
#        "s3:ListBucket",
#        "s3:GetBucketLocation",
#        "s3:PutObject",
#        "s3:PutObjectAcl",
#        "s3:GetObject",
#        "s3:GetObjectAcl",
#        "s3:DeleteObject"
#      ],
#      Resource = [
#        "arn:aws:s3:::doc-csd-pharmacy-data-dev",
#        "arn:aws:s3:::doc-csd-pharmacy-data-dev/*",
#        "arn:aws:s3:::doc-csd-pharmacy-import-data-dev",
#        "arn:aws:s3:::doc-csd-pharmacy-import-data-dev/*",
#        "arn:aws:s3:::doc-csd-uploaded-pharmacy-data-dev",
#        "arn:aws:s3:::doc-csd-uploaded-pharmacy-data-dev/*",
#        "arn:aws:s3:::doc-csd-cancelled-pharmacy-data-dev",
#        "arn:aws:s3:::doc-csd-cancelled-pharmacy-data-dev/*",
#        "arn:aws:s3:::doc-csd-pharmacy-data-at",
#        "arn:aws:s3:::doc-csd-pharmacy-data-at/*",
#        "arn:aws:s3:::doc-csd-pharmacy-import-data-at",
#        "arn:aws:s3:::doc-csd-pharmacy-import-data-at/*",
#        "arn:aws:s3:::doc-csd-uploaded-pharmacy-data-at",
#        "arn:aws:s3:::doc-csd-uploaded-pharmacy-data-at/*",
#        "arn:aws:s3:::doc-csd-cancelled-pharmacy-data-at",
#        "arn:aws:s3:::doc-csd-cancelled-pharmacy-data-at/*"
#      ]
#    }]
#  })
#}
#
#module "pharmacy_data" {
#  source    = "./pharmacyData"
#  labeltags = {
#    "env" = var.env
#    "contact" = "Trent Ady"
#    "dept" = "ulc"
#    "elcid" = "ICDTS"
#    "security" = "13"
#    "supportcode" = "hstsahsy"
#    "app" = "csd"
#  }
#}

module "security_groups" {
  source             = "./securityGroups"
  subnetPrivateACidr = data.aws_subnet.privateA.cidr_block
  subnetPrivateBCidr = data.aws_subnet.privateB.cidr_block
  subnetPublicACidr  = data.aws_subnet.publicA.cidr_block
  subnetPublicBCidr  = data.aws_subnet.publicB.cidr_block
  vpcId              = data.aws_vpc.mainVPC.id
  labeltags = {
    "env"         = var.env
    "contact"     = "Trent Ady"
    "dept"        = "ulc"
    "elcid"       = "ICDTS"
    "security"    = "1"
    "supportcode" = "hstsahsy"
  }
}

module "eb_mylc" {
  source      = "./beanstalk"
  vpc_id      = data.aws_vpc.mainVPC.id
  ec2_subnets = [data.aws_subnet.privateB.id, data.aws_subnet.privateA.id]
  elb_subnets = [data.aws_subnet.publicA.id, data.aws_subnet.publicB.id]
  elb_scheme  = "public"
  elb_security_groups       = [module.security_groups.Public_ELB]
  security_groups           = [module.security_groups.Myulc_App]
  service_name              = "ulc-mylc-prod"
  service_description       = "Mylc Application"
  eb_solution_stack_name    = "64bit Amazon Linux 2023 v4.2.3 running Corretto 17"
  healthcheck_response_code = "200"
  #healthcheck_url           = "/usr/share/nginx/html/index.html"
  healthcheck_url           = "/"
  instance_type             = "t3.large" #2 vcpus and 8GB Ram
  #ssh_key_name              = "csd-${var.env}"
  port                    = "80"
  http_listener_forwarded = true
  ssl_certificate_id      = var.utah_gov_cert
  xmx                     = "2048m"
  elb_timeout             = "600"
  labeltags = {
    "env"         = var.env
    "contact"     = "Trent Ady"
    "dept"        = "ulc"
    "elcid"       = "ICDTS"
    "security"    = "1"
    "supportcode" = "hstsahsy"
    "app"         = "mylc-prod"
  }
}

#resource "aws_iam_role_policy_attachment" "attachment_at_eb_csd_s3" {
#  role = module.eb_csd_jar.beanstalk_ec2_role_name
#  policy_arn = aws_iam_policy.read-write-delete-s3-storage.arn
#}

