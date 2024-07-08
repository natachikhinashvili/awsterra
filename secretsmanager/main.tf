resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
    name = "database-creds"    
    lifecycle {
        ignore_changes = []
    }
}

resource "aws_secretsmanager_secret_version" "password" {
    secret_id = aws_secretsmanager_secret.password.id
    secret_string = random_password.master.result
    lifecycle {
        prevent_destroy = false
    }
}