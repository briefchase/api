# Parameters
DOCKER_COMPOSE_VERSION := 2.20.3

# SETUP:
# Deploy
deploy: install_docker install_compose stop_containers prune_docker restart_docker build
	echo "Deploying..."
	sudo docker-compose -f docker-compose.yml up -d
# Rebuild
dev_build: install_docker install_compose restart_docker build
	echo "Building for development..."
	sudo docker-compose -f docker-compose.yml up
# Restart
dev_start:
	echo "Starting development containers..."
	sudo docker-compose -f docker-compose.yml up -d
# Murder
dev_stop:
	echo "Destroying development containers..."
	sudo docker-compose down

# CONFIGURATION:
# Make a new configuration file


new_config:
	echo "Creating a new configuration file from template..."
	cp config.template.json config.json

# Send config.json to server
send_config:
	@echo "Extracting EXTERNAL_URL from config.json..."
	@CONFIG_ENDPOINT="/set_config"; \
	EXTERNAL_URL=$$(grep 'EXTERNAL_URL' config.json | cut -d '"' -f 4); \
	if [ -z "$$EXTERNAL_URL" ]; then \
		echo "EXTERNAL_URL is not set in config.json. Please check the file."; \
		exit 1; \
	fi; \
	if [ "$$EXTERNAL_URL" = "localhost" ]; then \
		PROTOCOL="http"; \
	else \
		PROTOCOL="https"; \
	fi; \
	FULL_URL="$$PROTOCOL://$$EXTERNAL_URL$$CONFIG_ENDPOINT"; \
	echo "Sending configuration to the server at $$FULL_URL..."; \
	curl -k -L -X POST -H "Content-Type: application/json" -d @config.json $$FULL_URL


# CLEANUP:
# Uninstall docker and compose

# HELPERS:
build:
	echo "Building and launching Docker Compose..."
	sudo chmod 600 traefik/acme.json
	sudo docker-compose -f docker-compose.yml build
restart_docker:
	echo "Restarting Docker service..."
	sudo systemctl restart docker
stop_containers:
	echo "Stopping any running containers..."
	CONTAINERS_RUNNING=$$(sudo docker ps -aq)
	if [ -n "$$CONTAINERS_RUNNING" ]; then sudo docker stop $$CONTAINERS_RUNNING; else echo "No containers to stop."; fi
destroy_artifacts:
	echo "Pruning Docker system..."
	sudo docker system prune -a -f --volumes

# Install docker
install_docker:
	@echo "Checking for Docker installation..."
	@if [ -x "$$(command -v docker)" ]; then \
		echo "Docker is already installed"; \
	else \
		if [ ! -f "./get-docker.sh" ]; then \
			echo "Downloading get-docker.sh..."; \
			curl -fsSL https://get.docker.com -o get-docker.sh; \
		fi; \
		echo "Making get-docker.sh executable..."; \
		chmod +x get-docker.sh; \
		echo "Running get-docker.sh..."; \
		sudo ./get-docker.sh; \
	fi

# Install docker-compose
install_compose:
	@echo "Checking for Docker Compose installation..."
	@docker-compose --version || ( \
		echo "Installing Docker Compose..."; \
		sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose; \
		sudo chmod +x /usr/local/bin/docker-compose; \
	)


# Remove Docker and all its dependencies
remove_docker:
	echo "Uninstalling Docker..."
	-sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
	-sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io
	-sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker /run/docker
	-sudo rm -rf $$(type -P docker-compose) /usr/local/bin/docker-compose
	-sudo apt-key del $$(apt-key list | grep 'Docker' -B1 | head -n 1 | awk '{print $$2}') 2>/dev/null || true
	-sudo rm /etc/apt/sources.list.d/docker.list 2>/dev/null || true
	echo "Killing any remaining Docker processes..."
	-sudo pkill -SIGHUP dockerd 2>/dev/null || true
	echo "Docker has been removed."
	sudo apt-get update
	echo "Verifying Docker removal..."
	if [ -z "$$(type -P docker)" ]; then echo "Docker is not present, ready for a fresh installation."; else echo "Docker was not fully removed, please check the uninstallation steps manually."; fi
