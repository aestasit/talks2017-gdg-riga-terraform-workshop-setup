
data "aws_ami" "workshop_ubuntu_trusty" {
  most_recent = true
  filter {
    name = "name"                
    values = [ "devops-ubuntu-14-04-x64*" ]
  }
  owners = [ "self" ] 
}

data "aws_subnet" "workshop_subnet_primary" {
  cidr_block = "10.1.1.0/24"
}

data "aws_subnet" "workshop_subnet_secondary" {
  cidr_block = "10.1.2.0/24"
}

data "aws_security_group" "workshop_security_group" {
  name = "workshop_security"
}
