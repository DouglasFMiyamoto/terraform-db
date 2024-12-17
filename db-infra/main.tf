data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Environment"
    values = ["private"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnet_ids.private_subnets.ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow RDS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.eks_private_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t4g.micro"
  name                 = "dbLanchonete"
  username             = var.db_username
  password             = var.db_password
  publicly_accessible  = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "LanchoneteRDS"
  }
}
