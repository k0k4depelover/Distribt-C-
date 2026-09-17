declare -A images=(
  [distrib-orders-producer]=distribt-orders
  [distrib-orders-consumer]=distribt-orders-consumer
  [distribt-emails]=distribt-emails
  [distribt-products-api-read]=distribt-products-api-read
  [distribt-products-api-write]=distribt-products-api-write
  [distribt-products-consumer]=distribt-products-consumer
  [distribt-subscriptions]=distribt-subscriptions
  [distribt-subscriptions-consumer]=distribt-subscriptions-consumer
)

# Paso 2: tag + push de cada imagen local al nombre correcto en el registro
for local_name in "${!images[@]}"; do
  service_name="${images[$local_name]}"
  sudo docker tag "$local_name:latest" "localhost:5100/$service_name:latest"
  sudo docker push "localhost:5100/$service_name:latest"
done

# Paso 3: SOLO después de que todo esté publicado, forzar el redeployment de cada servicio
for service_name in "${images[@]}"; do
  aws ecs update-service --cluster distribt-ecs-cluster --service "$service_name" --force-new-deployment --endpoint-url=http://localhost:4566 --region us-east-1
done