
variable "project_name" {
  default = "my-cluster"
}

resource "random_id" "project_id" {
  byte_length = 8
}

resource "random_pet" "project_name" {
  length = 2
}



