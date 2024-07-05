resource "aws_ecr_repository" "nats_repo" {
  name = "natsrepo"
}

resource "null_resource" "docker_build_and_push" {
  provisioner "local-exec" {
    command = <<EOF
      $(aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.nats_repo.repository_url})
      sudo docker build -t ${aws_ecr_repository.nats_repo.repository_url}:latest ./coolweb/
      sudo docker push ${aws_ecr_repository.nats_repo.repository_url}:latest
    EOF
  }
  depends_on = [aws_ecr_repository.nats_repo]
}