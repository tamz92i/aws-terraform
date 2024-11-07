# Définition du backend S3 pour stocker l'état de Terraform
terraform {
  backend "s3" {
    bucket = "votre-bucket-terraform"  # Remplacez par le nom de votre bucket S3
    key    = "terraform/state/terraform.tfstate"  # Chemin du fichier d'état dans le bucket S3
    region = "us-east-1"  # Région où votre bucket S3 est créé
  }
}

# Provider AWS
provider "aws" {
  region = "us-east-1"  # 
}

# Définir la clé SSH pour accéder à l'instance EC2
resource "aws_key_pair" "key_pair" {
  key_name   = "tictactoe-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Remplacez avec le chemin vers votre clé publique SSH
}

# Créer une instance EC2 pour héberger l'application Tic-Tac-Toe
resource "aws_instance" "tictactoe_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Remplacez par l'AMI de votre choix (exemple: Amazon Linux 2)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  # Configuration de sécurité
  security_groups = [aws_security_group.sg.name]
  
  tags = {
    Name = "TicTacToeInstance"
  }

  # User data pour installer et démarrer Tic-Tac-Toe
  user_data = <<-EOF
              #!/bin/bash
              cd /home/ec2-user
              git clone https://github.com/Darhazer/nodejs-tic-tac-toe.git
              cd tictactoe
              # Exemple d'installation d'une app Python (à adapter selon votre projet)
              pip install -r requirements.txt
              python app.py
              EOF
}

# Créer un groupe de sécurité pour permettre l'accès HTTP
resource "aws_security_group" "sg" {
  name        = "tictactoe-sg"
  description = "Allow HTTP access"
  vpc_id      = "vpc-xxxxxxxx"  # Remplacez par l'ID de votre VPC (si nécessaire)

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic IP pour l'instance EC2 (facultatif)
resource "aws_eip" "tictactoe_ip" {
  instance = aws_instance.tictactoe_instance.id
}

# Output de l'adresse IP publique de l'instance
output "public_ip" {
  value = aws_instance.tictactoe_instance.public_ip
}

# S3 Bucket pour héberger les fichiers d'état de Terraform
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "votre-bucket-terraform"  # Remplacez par le nom du bucket S3 que vous souhaitez créer
  acl    = "private"
}

