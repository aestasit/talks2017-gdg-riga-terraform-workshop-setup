
output "ami_id" {
  value = "${data.aws_ami.workshop_ubuntu_trusty.image_id}"
}

output "subnet_id" {
  value = "${data.aws_subnet.workshop_subnet_primary.id}"
}

output "security_id" {
  value = "${data.aws_security_group.workshop_security_group.id}"
}

output "master_ip" {
  value = "${aws_instance.cluster_node.0.public_ip}"
}

output "cluster_ips" {
  value = "${aws_instance.cluster_node.*.public_ip}"
}

output "lb_dns" {
  value = "${aws_alb.cluster_lb.dns_name}"
}

output "kibana_ip" {
  value = "${aws_instance.kibana.public_ip}"
}
