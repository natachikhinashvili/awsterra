resource "aws_ecr_repository" "nats_repo" {
  name = var.repositoryname
}

resource "null_resource" "docker_build_and_push" {
  provisioner "local-exec" {
    command = <<EOF
      $(aws ecr get-login --no-include-email --region ${var.region})
      docker build -t ${aws_ecr_repository.nats_repo.repository_url}:latest .
      docker push ${aws_ecr_repository.nats_repo.repository_url}:latest
    EOF
  }
  depends_on = [aws_ecr_repository.nats_repo]
}
