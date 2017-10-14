
data "aws_ami" "workshop_ubuntu_trusty" {
  most_recent = true
  filter {
    name = "name"                
    values = [ "devops-ubuntu-14-04-x64*" ]
  }
  owners = [ "self" ] 
}

data "aws_availability_zones" "available" {}
