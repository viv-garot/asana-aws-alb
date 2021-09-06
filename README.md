## Description
AWS ASG + ALB + 2 ubuntu web instances + VPC + default_route_table + SGs

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
terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v3.57.0...
- Installed hashicorp/aws v3.57.0 (self-signed, key ID 34365D9472D7468F)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

* Apply:

```
terraform apply
```

_sample_:

```
 terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.aws_subnet_ids.subs will be read during apply
  # (config refers to values not yet known)
 <= data "aws_subnet_ids" "subs"  {
      + id     = (known after apply)
      + ids    = (known after apply)
      + tags   = (known after apply)
      + vpc_id = (known after apply)
    }

  # aws_alb_listener.http will be created
  + resource "aws_alb_listener" "http" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order = (known after apply)
          + type  = "fixed-response"

          + fixed_response {
              + content_type = "text/plain"
              + message_body = "404: page not found"
              + status_code  = "404"
            }
        }
    }
    
[ .... ]

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + alb_dns_name = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
  
[ .... ]

aws_autoscaling_group.ASG-WebServer: Creation complete after 1m18s [id=terraform-20210906142911336800000002]
aws_lb.lb-example: Still creating... [1m30s elapsed]
aws_lb.lb-example: Still creating... [1m40s elapsed]
aws_lb.lb-example: Still creating... [1m50s elapsed]
aws_lb.lb-example: Still creating... [2m0s elapsed]
aws_lb.lb-example: Still creating... [2m10s elapsed]
aws_lb.lb-example: Creation complete after 2m17s [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:loadbalancer/app/vivien-ASG/3e34ca9729d9699c]
aws_alb_listener.http: Creating...
aws_alb_listener.http: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:listener/app/vivien-ASG/3e34ca9729d9699c/a2597c7199694c3d]
aws_lb_listener_rule.asg: Creating...
aws_lb_listener_rule.asg: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:938620692197:listener-rule/app/vivien-ASG/3e34ca9729d9699c/a2597c7199694c3d/109903f546e61fbc]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "vivien-ASG-1183566190.eu-central-1.elb.amazonaws.com"

```

* Hit the Application Load balancer to confirm communication with the instances

```
curl $(terraform output -raw alb_dns_name):8080
```

_sample_:

```
curl $(terraform output -raw alb_dns_name):80
Sapee
```

_Or in a web browser:_

![image](https://user-images.githubusercontent.com/85481359/132232786-6a5470cb-fb9c-4d54-aad0-92cd90ec3171.png)


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
