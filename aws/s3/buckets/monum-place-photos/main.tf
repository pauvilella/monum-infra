resource "aws_s3_bucket" "monum_place_photos" {
  bucket = "monum-place-photos"
}

resource "aws_s3_bucket_policy" "monum_place_photos_policy" {
  bucket = aws_s3_bucket.monum_place_photos.id
  policy = data.aws_iam_policy_document.monum_place_photos_policy_document.json
}

data "aws_iam_policy_document" "monum_place_photos_policy_document" {

  statement {
    sid    = "EnforcedTLS"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.monum_place_photos.arn}/*",
      aws_s3_bucket.monum_place_photos.arn,
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "monum_place_photos" {
  bucket = aws_s3_bucket.monum_place_photos.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "monum_place_photos" {
  depends_on = [aws_s3_bucket_ownership_controls.monum_place_photos]

  bucket = aws_s3_bucket.monum_place_photos.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "monum_place_photos" {
  bucket = aws_s3_bucket.monum_place_photos.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "monum_place_photos" {
  bucket = aws_s3_bucket.monum_place_photos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "arn:aws:kms:eu-west-1:${local.account_id}:alias/aws/s3"
    }
  }
}
