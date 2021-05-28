provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA4PI4D6C44WB2SALW"
  secret_key = "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"
}

resource "aws_sqs_queue" "client_tci_dlq" {
  name                       = "client_tci_dlq"
  visibility_timeout_seconds = 30
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
  message_retention_seconds  = 1209600
  max_message_size           = 262144
}

resource "aws_sqs_queue" "clsqs_client_tci" {
  name                       = "clsqs_client_tci"
  visibility_timeout_seconds = 60
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.client_tci_dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue_policy" "clsqs_client_tci_policy" {
  queue_url = aws_sqs_queue.clsqs_client_tci.id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::857441824953:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.clsqs_client_tci.arn}"
    },
    {
      "Sid": "__sender_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::857441824953:user/umair@pumpjackdataworks.com"
      },
      "Action": "SQS:SendMessage",
       "Resource": "${aws_sqs_queue.clsqs_client_tci.arn}"
    },
    {
      "Sid": "__receiver_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::857441824953:user/umair@pumpjackdataworks.com"
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:${aws_sqs_queue.clsqs_client_tci.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "lambda:*",
      "Resource": "*"
    }
  ]
}
POLICY
}