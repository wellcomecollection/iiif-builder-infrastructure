# Lambda IAM
data "aws_iam_policy_document" "pdf_generator_exec_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pdf_generator_exec_role" {
  name               = "${local.environment}-pdf-gen-exec-role"
  assume_role_policy = data.aws_iam_policy_document.pdf_generator_exec_role.json
}

resource "aws_iam_role_policy_attachment" "pdf_generator_logging" {
  role       = aws_iam_role.pdf_generator_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "pdf_generator_read_presentation_bucket" {
  name   = "pdf-generator-read-stage-presentation-bucket"
  role   = aws_iam_role.pdf_generator_exec_role.name
  policy = data.aws_iam_policy_document.presentation_read.json
}

# Lambda Function
resource "aws_lambda_function" "pdf_generator" {
  function_name = "${local.environment}-pdf-generator"
  handler       = "generator.lambda_handler"
  filename      = "data/empty_pdf_gen.zip"
  runtime       = "python3.8"
  memory_size   = 128
  role          = aws_iam_role.pdf_generator_exec_role.arn

  environment {
    variables = {
      "MANIFEST_BUCKET" = aws_s3_bucket.presentation.id
      "KEY_PREFIX"      = "v3"
    }
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

# Target Group for Lambda
resource "aws_alb_target_group" "pdf_generator" {
  name                               = "${local.full_name}-pdf-generator"
  target_type                        = "lambda"
  lambda_multi_value_headers_enabled = false
}

resource "aws_lb_target_group_attachment" "pdf_generator" {
  target_group_arn = aws_alb_target_group.pdf_generator.arn
  target_id        = aws_lambda_function.pdf_generator.arn
  depends_on       = [aws_lambda_permission.allow_loadbalancer_call_pdf_generator]
}

resource "aws_lambda_permission" "allow_loadbalancer_call_pdf_generator" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdf_generator.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_alb_target_group.pdf_generator.arn
}
