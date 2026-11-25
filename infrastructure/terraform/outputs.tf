output "instance_id" {
  description = "The disposable EC2 instance identifier."
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Ephemeral public IPv4; not an Elastic IP."
  value       = aws_instance.bastion.public_ip
}

output "ssh_user" {
  description = "Default user for Amazon Linux 2023."
  value       = "ec2-user"
}

output "ssh_target" {
  description = "Convenience target; host-key identity must still be verified."
  value       = "ec2-user@${aws_instance.bastion.public_ip}"
}

output "account_id" {
  description = "Account guard expectation for operator verification."
  value       = var.expected_account_id
}
