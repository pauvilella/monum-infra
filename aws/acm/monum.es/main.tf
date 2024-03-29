resource "aws_acm_certificate" "cert" {
  domain_name       = "*.monum.es"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "cert_virg" {
  provider          = aws.virginia
  domain_name       = "*.monum.es"
  validation_method = "DNS"
}

data "aws_route53_zone" "monum_es" {
  name         = "monum.es"
  private_zone = false
}

resource "aws_route53_record" "validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.monum_es.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]
}

resource "aws_acm_certificate_validation" "cert_validation_virg" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert_virg.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]
}
