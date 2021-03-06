
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "admin@mlambda.net"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "demo.mlambda.net"

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_iam_server_certificate" "elb_cert" {
  name_prefix       = "demo-cert-"
  certificate_body  =  acme_certificate.certificate.certificate_pem
  private_key       = acme_certificate.certificate.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}

