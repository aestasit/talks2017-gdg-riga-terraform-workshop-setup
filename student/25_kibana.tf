
data "template_file" "kibana_config" {
  template = "${file("kibana.yml.tpl")}"
  vars {
    lb_host = "${aws_alb.cluster_lb.dns_name}"
  }
}

resource "aws_instance" "kibana" {
  ami = "${data.aws_ami.workshop_ubuntu_trusty.id}"
  instance_type = "t2.small"
  tags {
    Name = "${var.project_name}-node-${format("%02d", count.index + 1)}"
  }
  root_block_device {
    volume_size = "10"
  }
  key_name = "${aws_key_pair.student_key.key_name}"
  subnet_id = "${data.aws_subnet.workshop_subnet_primary.id}"
  vpc_security_group_ids = [ "${data.aws_security_group.workshop_security_group.id}" ]
  connection {
    user = "ubuntu"
    private_key = "${file("student.key")}"
  }
  provisioner "file" {
    content = "${data.template_file.kibana_config.rendered}"
    destination = "/tmp/kibana.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https",
      "echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list",
      "sudo apt-get update && sudo apt-get install kibana",
      "sudo cp /tmp/kibana.yml /etc/kibana/kibana.yml",
      "sudo service kibana restart"
    ]
  }
}
