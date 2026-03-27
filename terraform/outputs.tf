output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "ID of the EC2 instance (VM)"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP address of the server"
  value       = aws_instance.app.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 artifacts bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app.id
}