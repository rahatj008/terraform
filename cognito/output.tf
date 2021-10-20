output "pool-id" {
  value = aws_cognito_user_pool.pool.id
}

output "pool-client-id" {
  value = aws_cognito_user_pool_client.client.id
}