for img in distrib-orders-producer distrib-orders-consumer distribt-emails distribt-products-api-read distribt-products-api-write distribt-products-consumer distribt-subscriptions distribt-subscriptions-consumer; do
  sudo docker tag "$img:latest" "localhost:5100/$img:latest"
  sudo docker push "localhost:5100/$img:latest"
done
