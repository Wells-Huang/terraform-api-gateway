# ==========================================
# S3 Bucket - 靜態網站託管
# ==========================================

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${var.aws_region}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Static Website Bucket"
  }
}

# 啟用版本控制
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 設定為靜態網站託管
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"  # SPA 路由支援
  }
}

# 封鎖公開存取設定（我們將透過 bucket policy 控制）
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy - 允許公開讀取（透過 S3 Website Endpoint）
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# ==========================================
# S3 Bucket - TODO 資料儲存
# ==========================================

resource "aws_s3_bucket" "todo_data" {
  bucket = "${var.project_name}-todo-data-${var.aws_region}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "TODO Data Bucket"
  }
}

# 封鎖公開存取
resource "aws_s3_bucket_public_access_block" "todo_data" {
  bucket = aws_s3_bucket.todo_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS 配置
resource "aws_s3_bucket_cors_configuration" "todo_data" {
  bucket = aws_s3_bucket.todo_data.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["https://${aws_cloudfront_distribution.main.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ==========================================
# 資料來源
# ==========================================

data "aws_caller_identity" "current" {}
