# Parameters
URL_PREFIX = https://
URL_SUFFIX = /set_config
DOCKER_COMPOSE_VERSION := 2.20.3

# Make a new configuration file
new_config:
	# Copy config template file
	cp config.template.json config.json
# Send config.json to server
send_config:
	@EXTERNAL_URL=$$(awk -F '=' '/EXTERNAL_URL/ {print $$2}' .env); \
	FULL_URL=$$(echo "$(URL_PREFIX)$$EXTERNAL_URL$(URL_SUFFIX)"); \
	echo "Captured URL: $$FULL_URL"; \
	curl -k -L -X POST -H "Content-Type: application/json" -d @config.json $$FULL_URL
# Deploy on a server
deploy: check_docker stop_containers prune_docker \
        restart_docker install_docker_compose compose_up
# Deploy locally
local: 

# HELPERS:
check_docker:
	@if command -v docker &>/dev/null; then \
		echo "Docker is already installed"; \
	else \
		echo "Installing Docker..."; \
		curl -fsSL https://get.docker.com -o get-docker.sh; \
		sudo sh get-docker.sh; \
	fi
stop_containers:
	@echo "Stopping any running containers..."; \
	CONTAINERS_RUNNING=$$(sudo docker ps -aq); \
	if [ -n "$$CONTAINERS_RUNNING" ]; then \
		sudo docker stop $$CONTAINERS_RUNNING; \
	else \
		echo "No containers to stop"; \
	fi
prune_docker:
	@echo "Pruning Docker system..."; \
	sudo docker system prune -a -f --volumes
restart_docker:
	@echo "Restarting Docker service..."; \
	sudo systemctl restart docker
install_docker_compose:
	@echo "Installing Docker Compose version $(DOCKER_COMPOSE_VERSION)..."; \
	sudo curl -SL "https://github.com/docker/compose/releases/download/v$(DOCKER_COMPOSE_VERSION)/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose; \
	sudo chmod +x /usr/local/bin/docker-compose
compose_up:
	@echo "Building and launching Docker Compose..."; \
	sudo chmod 600 traefik/acme.json; \
	sudo docker-compose -f docker-compose.yml build; \
	sudo docker-compose -f docker-compose.yml up
