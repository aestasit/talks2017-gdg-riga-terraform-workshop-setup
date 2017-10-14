
output "api_keys" {
  value = ["${zipmap(aws_iam_access_key.student_key.*.id,aws_iam_access_key.student_key.*.secret)}"]
}
