
variable "node_count" {
  default = "2"
}

data "template_file" "es_config" {
  template = "${file("elasticsearch.yml.tpl")}"
  vars {
    cluster_name = "${var.project_name}"
  }
}

data "template_file" "jvm_opts" {
  template = "${file("jvm.options.tpl")}"
}

resource "aws_instance" "cluster_node" {
  count = "${var.node_count}"
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
    content = "${data.template_file.es_config.rendered}"
    destination = "/tmp/elasticsearch.yml"
  }
  provisioner "file" {
    content = "${data.template_file.jvm_opts.rendered}"
    destination = "/tmp/jvm.options"
  }
  provisioner "remote-exec" {
    inline = [
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https",
      "echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list",
      "sudo apt-get update && sudo apt-get install elasticsearch",
      "sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-file",
      "sudo cp /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
      "sudo cp /tmp/jvm.options /etc/elasticsearch/jvm.options",
      "sudo service elasticsearch restart"
    ]
  }
}
