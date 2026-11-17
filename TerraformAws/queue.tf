# 1. SQS Queue
resource "aws_sqs_queue" "greet_queue" {
  name = "greeter-queue"
}
