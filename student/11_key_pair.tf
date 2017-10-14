
resource "aws_key_pair" "student_key" {
  key_name = "${var.project_name}-student-key" 
  public_key = "${file("student.pub")}"
}
