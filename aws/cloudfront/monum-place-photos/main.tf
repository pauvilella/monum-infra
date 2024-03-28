locals {
  domain    = "media.monum.es"
  origin_id = "monum-place-photos"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI monum-place-photos"
}

data "aws_cloudfront_cache_policy" "managed-cachingdisabled" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_cache_policy" "managed-cachingoptimized" {
  name = "Managed-CachingOptimized"
}
data "aws_cloudfront_origin_request_policy" "managed-cors-s3origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_distribution" "monum_place_photos" {
  comment = local.domain

  aliases = [
    "${local.domain}"
  ]

  wait_for_deployment = false
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  origin {
    domain_name = "monum-place-photos.s3.amazonaws.com"
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {

    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["HEAD", "GET"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingdisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  ordered_cache_behavior {
    path_pattern     = "/*.png"
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingoptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  ordered_cache_behavior {
    path_pattern     = "/*.jpg"
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingoptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  ordered_cache_behavior {
    path_pattern     = "/*.jpeg"
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingoptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  ordered_cache_behavior {
    path_pattern     = "/*.webp"
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingoptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  ordered_cache_behavior {
    path_pattern     = "/*.mp4"
    target_origin_id = local.origin_id
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET", "POST", "HEAD", "PATCH", "DELETE", "OPTIONS", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = data.aws_cloudfront_cache_policy.managed-cachingoptimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed-cors-s3origin.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:670989880542:certificate/ff12bc1c-46ae-48ee-bf20-35eabff91083" # virginia cert
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "media_monum_es" {
  zone_id = "Z095609119NLCFOW36CSG" # monum.es
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.monum_place_photos.domain_name
    zone_id                = aws_cloudfront_distribution.monum_place_photos.hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_iam_policy_document" "monum_place_photos_bucket_policy" {
  # Statement for Cloudfront OAI
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = ["arn:aws:s3:::${local.origin_id}/*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.oai.iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "monum_place_photos_bucket_policy" {
  bucket = local.origin_id
  policy = data.aws_iam_policy_document.monum_place_photos_bucket_policy.json
}
