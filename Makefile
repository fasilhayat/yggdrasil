# Start all services
run-local:
	docker-compose up -d

# Stop all services
down:
	docker-compose down

# Restart all services
restart: down up

# Show running containers
ps:
	docker-compose ps

# Show logs for all services
logs:
	docker-compose logs -f

# Show logs for Prometheus
prometheus:
	docker-compose logs -f prometheus

# Show logs for Grafana
grafana:
	docker-compose logs -f grafana

# Remove all volumes and containers
clean:
	docker-compose down -v --remove-orphans

# make up         # Start Prometheus and Grafana
# make logs       # See combined logs
# make grafana    # See only Grafana logs
# make prometheus # See only Prometheus logs
# make down       # Stop containers
# make clean      # Stop + remove all volumes