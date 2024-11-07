# Configuration du fournisseur AWS
provider "aws" {
  region = "us-east-1"
}

# Définir un bucket S3 pour stocker l'état de Terraform
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "votre-bucket-terraform"
  acl    = "private"
}

# Utilisation d'une ressource dédiée pour l'ACL du bucket
resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  acl    = "private"
}

# Créer une paire de clés SSH
resource "aws_key_pair" "key_pair" {
  key_name   = "my-key"
  # Assurez-vous que le chemin vers la clé publique est correct
  public_key = file("/home/cloudshell-user/.ssh/id_rsa.pub")  # Remplacez ce chemin si nécessaire
}

# Création d'une instance EC2 pour déployer le Tic-Tac-Toe
resource "aws_instance" "tictactoe_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Remplacez par l'AMI que vous voulez utiliser
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  # Configuration du groupe de sécurité (ouverture du port HTTP)
  security_groups = [aws_security_group.tictactoe_sg.name]

  # Tagging de l'instance
  tags = {
    Name = "Tic-Tac-Toe Instance"
  }
}

# Sécurité pour l'instance EC2 (autorisation HTTP)
resource "aws_security_group" "tictactoe_sg" {
  name        = "tictactoe_sg"
  description = "Allow HTTP traffic"
  
  # Autoriser le trafic HTTP sur le port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Autoriser le trafic SSH pour l'accès à l'instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Créer un bucket S3 pour stocker l'application Tic-Tac-Toe (optionnel)
resource "aws_s3_bucket" "tictactoe_bucket" {
  bucket = "votre-tictactoe-bucket"
  acl    = "private"
}

# Créer une ressource AWS EC2 pour déployer l'application
resource "aws_instance" "tictactoe_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Remplacez par l'AMI appropriée pour votre application
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.tictactoe_sg.name]

  # Définition des tags pour l'instance EC2
  tags = {
    Name = "TicTacToe Instance"
  }
}

# Pour l'initialisation et la configuration du S3 backend (optionnel)
terraform {
  backend "s3" {
    bucket = "votre-bucket-terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
