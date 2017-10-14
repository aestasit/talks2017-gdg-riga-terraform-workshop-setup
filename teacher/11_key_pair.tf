
resource "aws_key_pair" "workshop_key" {
  key_name = "workshop_key" 
  public_key = "${file("workshop.pub")}"
}
