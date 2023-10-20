# Check if Docker is installed and take necessary actions
check-docker:
	@if command -v docker &>/dev/null; then \
		CONTAINERS_RUNNING=$$(sudo docker ps -aq); \
		if [ ! -z "$$CONTAINERS_RUNNING" ]; then \
			sudo docker stop $$CONTAINERS_RUNNING; \
		else \
			echo "No containers to stop"; \
		fi; \
		CONTAINERS_STOPPED=$$(sudo docker ps -a -q); \
		if [ ! -z "$$CONTAINERS_STOPPED" ]; then \
			sudo docker rm -f $$CONTAINERS_STOPPED; \
		fi; \
		sudo systemctl restart docker; \
	else \
		curl -fsSL https://get.docker.com -o get-docker.sh; \
		sudo sh get-docker.sh; \
	fi

# Install Docker Compose
install-compose:
	sudo curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

# Build and start services defined in the Docker Compose file
compose-up:
	sudo chmod 600 traefik/acme.json
	sudo docker-compose -f docker-compose.yml build
	sudo docker-compose -f docker-compose.yml up -d

# All-in-one target to run everything
docker: check-docker install-compose compose-up

# Send config.json to server
config:
	# Copy config template file
	cp config.template.json config.json

# Send config.json to server
send_config:
	# Extract EXTERNAL_URL from .env file
	EXTERNAL_URL=$(awk -F'[:," ]+' '/"EXTERNAL_URL"/ {for(i=1;i<=NF;i++) if($i=="EXTERNAL_URL") print $(i+2); exit}' .env)
	# Send config.json via HTTPS POST to the extracted URL
	curl -X POST -H "Content-Type: application/json" -d @config.json $EXTERNAL_URL
