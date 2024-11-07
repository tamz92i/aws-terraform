provider "aws" {
  region = "us-east-1"
}

# S3 Backend pour le stockage de l'état Terraform
terraform {
  backend "s3" {
    bucket = "tf-state-lab-florent"
    key    = "tictactoe/tf-state"
    region = "us-east-1"
  }
}

# Dépôt ECR pour stocker l'image Docker
resource "aws_ecr_repository" "tictactoe_repo" {
  name = "tictactoe-app"
}

# Cluster ECS
resource "aws_ecs_cluster" "tictactoe_cluster" {
  name = "tictactoe-cluster"
}

# Table DynamoDB pour stocker les données de jeu Tic-Tac-Toe
resource "aws_dynamodb_table" "tictactoe_table" {
  name           = "TicTacToeGame"
  hash_key       = "GameId"
  attribute {
    name = "GameId"
    type = "S"
  }
  read_capacity  = 5
  write_capacity = 5
}

# Définition de la tâche ECS pour l'application
resource "aws_ecs_task_definition" "tictactoe_task_def" {
  family                   = "tictactoe-task"
  container_definitions    = jsonencode([{
    name  = "tictactoe-container"
    image = "${aws_ecr_repository.tictactoe_repo.repository_url}:latest"
    memory = 512
    cpu    = 256
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    environment = [{
      name  = "DYNAMODB_TABLE"
      value = aws_dynamodb_table.tictactoe_table.name
    }]
  }])
}

# Service ECS
resource "aws_ecs_service" "tictactoe_service" {
  name            = "tictactoe-service"
  cluster         = aws_ecs_cluster.tictactoe_cluster.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.tictactoe_task_def.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [var.subnet_id]
    assign_public_ip = true
    security_groups = [aws_security_group.tictactoe_sg.id]
  }
}

# Security Group pour l'accès au service
resource "aws_security_group" "tictactoe_sg" {
  name_prefix = "tictactoe-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

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

# Variables pour VPC et Subnet
variable "vpc_id" {}
variable "subnet_id" {}

output "ecr_repository_url" {
  value = aws_ecr_repository.tictactoe_repo.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.tictactoe_cluster.name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tictactoe_table.name
}
