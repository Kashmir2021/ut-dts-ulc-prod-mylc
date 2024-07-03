resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "${var.service_name}-${var.labeltags.env}-beanstalk-service-user"
  role = aws_iam_role.beanstalk_service.name
}
resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "${var.service_name}-${var.labeltags.env}-beanstalk-ec2-user"
  role = aws_iam_role.beanstalk_ec2.name
}
resource "aws_iam_role" "beanstalk_service" {
  name = "${var.service_name}-${var.labeltags.env}-beanstalk-service-role"
  tags = var.labeltags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role" "beanstalk_ec2" {
  name               = "${var.service_name}-${var.labeltags.env}-beanstalk-ec2-role"
  tags               = var.labeltags
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "beanstalk_service" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_role_policy_attachment" "beanstalk_service_health" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_web" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_ssm" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_ssm_patch" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}
resource "aws_iam_policy" "beanstalk_ec2_tags" {
  name       = "${var.service_name}-${var.labeltags.env}-elastic-beanstalk-ec2-tags"
  description = "Allow instance to get instance tags"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags",
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_tags" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = aws_iam_policy.beanstalk_ec2_tags.arn
}
resource "aws_iam_role_policy_attachment" "beanstalk_service_ec2_tags" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = aws_iam_policy.beanstalk_ec2_tags.arn
}
resource "aws_iam_policy" "beanstalk_ec2_secrets" {
  name       = "${var.service_name}-${var.labeltags.env}-elastic-beanstalk-ec2-secrets"
  description = "Allow instance to get secrets"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_secrets" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = aws_iam_policy.beanstalk_ec2_secrets.arn
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}-${var.labeltags.env}"
  description = var.service_description
  tags        = var.labeltags
}

resource "aws_elastic_beanstalk_configuration_template" "eb_template" {
  name                = "${var.service_name}-${var.labeltags.env}-template-config"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = var.eb_solution_stack_name
}

resource "aws_elastic_beanstalk_environment" "eb_env" {
  name                = "${var.service_name}-${var.labeltags.env}"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = var.eb_solution_stack_name

  dynamic "setting" {
    for_each = local.elb_settings_final
    content {
      name      = setting.value["name"]
      namespace = setting.value["namespace"]
      value     = setting.value["value"]
      resource  = ""
    }
  }

  dynamic "setting" {
    for_each = local.tomcat_settings_final
    content {
      name      = setting.value["name"]
      namespace = setting.value["namespace"]
      value     = setting.value["value"]
      resource  = ""
    }
  }

  dynamic "setting" {
    for_each = local.java_settings_final
    content {
      name      = setting.value["name"]
      namespace = setting.value["namespace"]
      value     = setting.value["value"]
      resource  = ""
    }
  }

  setting {
    name      = "ENV"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "${var.labeltags.env}"
    resource  = ""
  }
  setting {
    name      = "MatcherHTTPCode"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    resource  = ""
    value     = var.healthcheck_response_code
  }
  setting {
    name      = "StickinessEnabled"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    resource  = ""
    value     = "true"
  }
  # VPC settings
  setting {
    name      = "VPCId"
    namespace = "aws:ec2:vpc"
    value     = var.vpc_id
    resource  = ""
  }
  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = join(",", sort(var.ec2_subnets))
    resource  = ""
  }

  # EC2 settings
  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.instance_type
    resource  = ""
  }
  setting {
    name      = "RootVolumeType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.instance_volume_type
    resource  = ""
  }
  setting {
    name      = "RootVolumeSize"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.instance_volume_size
    resource  = ""
  }
  #setting {
  #  name      = "RootVolumeIOPS"
  #  namespace = "aws:autoscaling:launchconfiguration"
  #  value     = var.instance_volume_iops
  #  resource  = ""
  #}
  setting {
    name      = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.ssh_key_name
    resource  = ""
  }
  setting {
    name      = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = join(",", sort(var.security_groups))
    resource  = ""
  }
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.beanstalk_ec2.name
    resource  = ""
  }
  setting {
    name      = "UpdateLevel"
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    value     = "minor"
    resource  = ""
  }
  setting {
    name      = "InstanceRefreshEnabled"
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    value     = "true"
    resource  = ""
  }
  setting {
    name      = "DisableIMDSv1"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "true"
    resource  = ""
  }
  setting {
    name      = "LaunchTemplateTagPropagationEnabled"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "true"
    resource  = ""
  }

  # Configure rolling deployments for your application code.
  setting {
    name      = "DeploymentPolicy"
    namespace = "aws:elasticbeanstalk:command"
    value     = var.deployment_policy
    resource  = ""
  }
  setting {
    name      = "IgnoreHealthCheck"
    namespace = "aws:elasticbeanstalk:command"
    value     = var.ignore_healthcheck
    resource  = ""
  }
  setting {
    name      = "SystemType"
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    value     = var.healthreporting
    resource  = ""
  }

  # Configure your environment's architecture and service role.
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = var.environment_type
    resource  = ""
  }

  # Configure a health check path for your application. (ELB Healthcheck)
  setting {
    name      = "Application Healthcheck URL"
    namespace = "aws:elasticbeanstalk:application"
    value     = var.healthcheck_url
    resource  = ""
  }
  #Configure instance logs to stream to Cloudwatch and keep them for 90 days
  setting {
    name      = "StreamLogs"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    resource  = ""
    value     = "true"
  }
  setting {
    name      = "RetentionInDays"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    resource  = ""
    value     = "90"
  }
  tags = var.labeltags
}

## This adds redirect
data "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_elastic_beanstalk_environment.eb_env.load_balancers[0]
  port = 80
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  # The count attribute is used to determine whether to build this resource or not.
  # If the var.http_listener_forwarded variable is set to true then count is set 1 and the resource is built,
  # otherwise count is set to 0 and the resource is not built.
  # The default value for var.http_listener_forwarded is false.
  count = var.http_listener_forwarded ? 1 : 0
  listener_arn = data.aws_lb_listener.http_listener.arn
  priority = 1

  action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}


locals {
  elb_settings = [
    #    {
    #      name      = "ConnectionDrainingEnabled"
    #      namespace = "aws:elb:policies"
    #      value     = "true"
    #      resource  = ""
    #    },
    #    {
    #      name      = "ConnectionSettingIdleTimeout"
    #      namespace = "aws:elb:policies"
    #      value     = "60"
    #      resource  = ""
    #    },
    #    {
    #      name      = "CrossZone"
    #      namespace = "aws:elb:loadbalancer"
    #      value     = "true"
    #      resource  = ""
    #    },
    {
      name      = "ELBSubnets"
      namespace = "aws:ec2:vpc"
      value     = join(",", sort(var.elb_subnets))
      resource  = ""
    },
    #    {
    #      name      = "SecurityGroups"
    #      namespace = "aws:elb:loadbalancer"
    #      value     = join(",", sort(var.elb_security_groups))
    #      resource  = ""
    #    },
    #    {
    #      name      = "InstancePort"
    #      namespace = "aws:elb:listener"
    #      value     = var.port
    #      resource  = ""
    #    },
    #    {
    #      name      = "ListenerEnabled"
    #      namespace = "aws:elb:listener"
    #      value     = var.http_listener_enabled || var.ssl_certificate_id == "" ? "true" : "false"
    #      resource  = ""
    #    },
    #    {
    #      name      = "ListenerProtocol"
    #      namespace = "aws:elb:listener:443"
    #      value     = "HTTPS"
    #      resource  = ""
    #    },
    #    {
    #      name      = "InstancePort"
    #      namespace = "aws:elb:listener:443"
    #      value     = var.port
    #      resource  = ""
    #    },
    #    {
    #      name      = "SSLCertificateId"
    #      namespace = "aws:elb:listener:443"
    #      value     = var.ssl_certificate_id
    #      resource  = ""
    #    },    
    {
      name      = "IdleTimeout"
      namespace = "aws:elbv2:loadbalancer"
      value     = "300"
      resource  = ""
    },
    {
      name      = "SecurityGroups"
      namespace = "aws:elbv2:loadbalancer"
      value     = join(",", sort(var.elb_security_groups))
      resource  = ""
    },
    {
      name      = "ManagedSecurityGroup"
      namespace = "aws:elbv2:loadbalancer"
      value     = var.loadbalancer_managed_security_group
      resource  = ""
    },
    {
      name      = "ListenerEnabled"
      namespace = "aws:elbv2:listener:default"
      value     = var.http_listener_enabled || var.ssl_certificate_id == "" ? "true" : "false"
      resource  = ""
    },
    {
      name      = "ListenerEnabled"
      namespace = "aws:elbv2:listener:443"
      value     = var.ssl_certificate_id == "" ? "false" : "true"
      resource  = ""
    },
    {
      name      = "Protocol"
      namespace = "aws:elbv2:listener:443"
      value     = "HTTPS"
      resource  = ""
    },
    {
      name      = "SSLCertificateArns"
      namespace = "aws:elbv2:listener:443"
      value     = var.ssl_certificate_id
      resource  = ""
    },
    {
      name      = "SSLPolicy"
      namespace = "aws:elbv2:listener:443"
      value     = var.loadbalancer_ssl_policy
      resource  = ""
    },
    {
      name      = "ELBScheme"
      namespace = "aws:ec2:vpc"
      value     = var.tier_environment_type == "LoadBalanced" ? var.elb_scheme : ""
      resource  = ""
    },
    {
      name      = "LoadBalancerType"
      namespace = "aws:elasticbeanstalk:environment"
      value     = "application"
      resource  = ""
    },
    ###===================== Application Load Balancer Health check settings =====================================================###
    # The Application Load Balancer health check does not take into account the Elastic Beanstalk health check path
    # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-cfg-applicationloadbalancer.html
    # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-cfg-applicationloadbalancer.html#alb-default-process.config
    {
      name      = "HealthCheckPath"
      namespace = "aws:elasticbeanstalk:environment:process:default"
      value     = var.healthcheck_url
      resource  = ""
    },
    {
      name      = "Port"
      namespace = "aws:elasticbeanstalk:environment:process:default"
      value     = var.port
      resource  = ""
    },
    {
      name      = "ServiceRole"
      namespace = "aws:elasticbeanstalk:environment"
      value     = aws_iam_role.beanstalk_service.arn
      resource  = ""
    },
  ]
  elb_settings_final = var.tier == "WebServer" ? local.elb_settings : []

  tomcat_settings = [
    {
      name      = "Xms"
      namespace = "aws:elasticbeanstalk:container:tomcat:jvmoptions"
      value     = var.xms
      resource  = ""
    },
    {
      name      = "Xmx"
      namespace = "aws:elasticbeanstalk:container:tomcat:jvmoptions"
      value     = var.xmx
      resource  = ""
    },
  ]
  is_tomcat = contains(regex("^(?:.*(Tomcat))?.*$",var.eb_solution_stack_name), "Tomcat")
  tomcat_settings_final = local.is_tomcat ? local.tomcat_settings : []

  java_settings = [
    {
      name      = "SERVER_PORT"
      namespace = "aws:elasticbeanstalk:application:environment"
      value     = "5000"
      resource  = ""
    },
  ]
  java_settings_final = !local.is_tomcat && var.tier == "WebServer" ? local.java_settings : []

}  

