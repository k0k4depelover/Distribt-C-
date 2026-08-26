locals {
  microservices = [
    # Emails
    "distribt-emails",
    
    # Orders
    "distribt-orders",
    "distribt-orders-consumer",
    
    # Products
    "distribt-products-api-read",
    "distribt-products-api-write",
    "distribt-products-consumer",
    
    # Subscriptions
    "distribt-subscriptions",
    "distribt-subscriptions-consumer"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.microservices)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Environment = "local"
    Project     = "Distribt"
  }
}
