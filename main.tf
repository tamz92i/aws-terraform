provider "aws" {
  region = "us-east-1"  # Choisissez la région de votre choix
}

resource "aws_instance" "tictactoe" {
  ami           = "ami-0c55b159cbfafe1f0"  # Remplacez par un ID d'AMI valide
  instance_type = "t2.micro"  # Vous pouvez ajuster le type d'instance selon vos besoins
  key_name      = "lol"  # Remplacez par le nom de votre clé SSH

  security_groups = ["tictactoe-sg"]

  tags = {
    Name = "TicTacToeInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              cd /home/ec2-user
              git clone https://github.com/aqeelanwar/Tic-Tac-Toe.git
              cd tictactoe
              npm install
              npm start
              EOF
}

resource "aws_security_group" "tictactoe-sg" {
  name        = "tictactoe-sg"
  description = "Permet l'accès SSH et HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
