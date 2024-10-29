resource "aws_instance" "k8_master" {
  ami                         = "ami-085f9c64a9b75eed5"
  instance_type               = "t2.medium"
  key_name                    = var.KEYPAIR
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.global_public_subnet_a.id
  security_groups             = [aws_security_group.global_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install micro -y
              curl -sfL https://get.k3s.io | sh -s - server --tls-san ${var.K8S_DOMAIN_NAME}
              echo "alias kb='sudo k3s kubectl'" | tee -a /home/ubuntu/.bashrc
              echo "alias kubectl='sudo k3s kubectl'" | tee -a /home/ubuntu/.bashrc
              EOF

  tags = {
    Name = "${local.environment}-${local.project}-ec2-k8-master"
  }
}
# resource "aws_instance" "k8_slave" {
#   ami                         = "ami-085f9c64a9b75eed5"
#   instance_type               = "t2.micro"
#   key_name                    = aws_key_pair.ec2_keypair.key_name
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.global_public_subnet_b.id
#   security_groups             = [aws_security_group.global_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               apt update
#               apt install micro -y
#               curl -sfL https://get.k3s.io | sh -
#               echo "alias kb='sudo k3s kubectl'" | tee -a /home/ubuntu/.bashrc
#               echo "alias kubectl='sudo k3s kubectl'" | tee -a /home/ubuntu/.bashrc
#               EOF

#   tags = {
#     Name = "${local.environment}-${local.project}-ec2-k8-slave"
#   }
# }