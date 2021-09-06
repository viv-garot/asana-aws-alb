## Description
AWS ASG + ALB + 2 Web instances

## Pre-requirements

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) 
* [Terraform cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [aws account](https://aws.amazon.com/getting-started/?nc1=h_ls)

## How to use this repo

- Clone
- Run
- Cleanup

---

### Clone the repo

```
git clone https://github.com/viv-garot/asana-aws-alb
```

### Change directory

```
cd asana-aws-alb
```

### Run

* Init:

```
terraform init
```

_sample_:

```

```

* Apply:

```
terraform apply
```

_sample_:

```

```

* Wait a few minutes and hit the Application Load balancer

```
curl $(terraform output -raw alb_dns_name):8080
```

_sample_:

```
curl $(terraform output -raw alb_dns_name):80
Sapee
```

### Cleanup

```
terraform destroy
```

_sample_:

```
terraform destroy --auto-approve
aws_default_route_table.route: Destroying... [id=rtb-007fbad642e44dac5]
aws_lb_listener_rule.asg: Destroying... [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:listener-rule/app/vivien-ASG/a6a916620e443e7b/c4ce6ec98daa1f81/94eea690959f5522]
aws_default_route_table.route: Destruction complete after 0s
aws_autoscaling_group.ASG-WebServer: Destroying... [id=terraform-20210906134146824500000002]
aws_lb_listener_rule.asg: Destruction complete after 0s
aws_alb_listener.http: Destroying... [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:listener/app/vivien-ASG/a6a916620e443e7b/c4ce6ec98daa1f81]
aws_alb_listener.http: Destruction complete after 0s

[....]

aws_autoscaling_group.ASG-WebServer: Still destroying... [id=terraform-20210906134146824500000002, 1m40s elapsed]
aws_autoscaling_group.ASG-WebServer: Destruction complete after 1m41s
aws_launch_configuration.webserver: Destroying... [id=terraform-20210906134136881600000001]
aws_lb_target_group.asg: Destroying... [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:targetgroup/asg-example-WS/f2c602dd4bc401a2]
aws_lb_target_group.asg: Destruction complete after 1s
aws_launch_configuration.webserver: Destruction complete after 1s
aws_security_group.instance: Destroying... [id=sg-05fa2d86e3df11c22]
aws_security_group.instance: Destruction complete after 0s
aws_vpc.main: Destroying... [id=vpc-05224d941b152f3b9]
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 13 destroyed.
```
