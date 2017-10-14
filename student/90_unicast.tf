
data "template_file" "unicast_config" {
  template = "${file("unicast_hosts.txt.tpl")}"
  vars {
    master_ip = "${aws_instance.cluster_node.0.public_ip}"
  }
}

resource "local_file" "unicast_config" {
  content  = "${data.template_file.unicast_config.rendered}"
  filename = "unicast_hosts.txt"
}

resource "null_resource" "copy_cluster_config" {
  count = "${var.node_count}"
  provisioner "local-exec" {
    command = "scp -i student.key -o StrictHostKeyChecking=no unicast_hosts.txt ubuntu@${aws_instance.cluster_node.*.public_ip[count.index]}:/tmp"
  }
  provisioner "local-exec" {
    command = "ssh -i student.key -o StrictHostKeyChecking=no ubuntu@${aws_instance.cluster_node.*.public_ip[count.index]} sudo cp /tmp/unicast_hosts.txt /etc/elasticsearch"
  }
  provisioner "local-exec" {
    command = "ssh -i student.key -o StrictHostKeyChecking=no ubuntu@${aws_instance.cluster_node.*.public_ip[count.index]} sudo service elasticsearch restart"
  }
  depends_on = [ "aws_instance.cluster_node" ]
}

