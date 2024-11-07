# Fournisseur AWS
provider "aws" {
  region = "us-east-1"  # Ajustez selon la région souhaitée
}

# Générer un suffixe aléatoire pour rendre le nom du bucket unique
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Création du Bucket S3
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "votre-bucket-terraform-${random_id.bucket_suffix.hex}"
}

# Configuration des permissions du bucket S3
resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  acl    = "private"
}

# Création de la paire de clés SSH pour l'instance EC2
resource "aws_key_pair" "key_pair" {
  key_name   = "tictactoe-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Assurez-vous que ce fichier est présent sur votre machine
}

# Lancer une instance EC2 pour le Tic-Tac-Toe
resource "aws_instance" "tictactoe_instance" {
  ami           = "ami-063d43db0594b521b"  # ID de l'AMI Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  tags = {
    Name = "TicTacToe-Instance"
  }
}

# Lancer une autre instance EC2 pour le Tic-Tac-Toe
resource "aws_instance" "tictactoe_ec2" {
  ami           = "ami-063d43db0594b521b"  # ID de l'AMI Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  tags = {
    Name = "TicTacToe-EC2"
  }
}
