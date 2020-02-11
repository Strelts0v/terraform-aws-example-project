output "pet_project_elb_url" {
  value = aws_elb.pet_project.dns_name
}
