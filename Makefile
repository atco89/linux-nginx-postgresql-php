# ------------------------------------------------
# Variables
# ------------------------------------------------
DOCKER_DIR			:= $(PWD)/docker
ENV_FILE_PATH		:= $(DOCKER_DIR)/.env

-include $(ENV_FILE_PATH)

NGINX_DIR			:= $(DOCKER_DIR)/nginx
CERTS_DIR			:= $(NGINX_DIR)/certs
OPENSSL_DIR			:= $(NGINX_DIR)/openssl
BASIC_AUTH_DIR		:= $(NGINX_DIR)/authentication

.ONESHELL:
.PHONY: init # Copy appropriate environment file based on user choice.
init:
	@read -r -p "PLEASE CHOOSE YOUR ENVIRONMENT [local/prod]: " environment;
	cp -rf "$(ENV_FILE_PATH).$$environment" "$(ENV_FILE_PATH)"
	@echo "Environment initialized for: $$environment."
	@echo "Use 'make help' to view available commands. Set up the environment with 'make help'."

.PHONY: help # Display the help information for commands.
help:
	clear
	@echo "-----------------------------------------------------------------------------------------------------------"
	@echo "LIST OF AVAILABLE COMMANDS [DOCKER]"
	@echo "-----------------------------------------------------------------------------------------------------------"
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1:\t\2/' | column -ts "$$(printf '\t')"
	@echo "-----------------------------------------------------------------------------------------------------------"

.PHONY: hard # Initiate `.env`, clear containers, images, volumes, files, generate certs, and then start.
hard:
	-rm -f $(ENV_FILE_PATH)

	$(MAKE) init \
 		clean \
 		remove \
 	  	certs \
 	  	dhparam \
 	  	build

.PHONY: start # Simplified version of a `hard` command: Clear containers and initiate the application.
start:
	$(MAKE) clean \
		build

.PHONY: clean # Clean up Docker resources.
clean:
	- docker kill $$(docker ps -q)
	- docker volume rm $$(docker volume ls -q)
	- docker system prune -a -f --volumes

.PHONY: remove # Remove all generated files.
remove:
	- rm -rf $(DOCKER_DIR)/database/postgres/data \
 		$(BASIC_AUTH_DIR) \
 		$(CERTS_DIR) \
 		$(NGINX_DIR)/logs

.PHONY: certs # Generate a self-signed SSL certificate.
certs:
	@if [ ! -d $(CERTS_DIR) ] ; then \
		mkdir -m 0777 $(CERTS_DIR); \
	fi

	@if [ ! -f $(CERTS_DIR)/server.pem ] || [ ! -f $(CERTS_DIR)/server.crt ]; then \
		openssl req \
			-utf8 \
			-x509 \
			-nodes \
			-days 365 \
			-newkey rsa:4096 \
			-keyout $(CERTS_DIR)/server.pem \
			-out $(CERTS_DIR)/server.crt \
			-config $(OPENSSL_DIR)/openssl.cnf; \
	fi

.PHONY: dhparam # Generate Diffie-Hellman (DH) key exchange file.
dhparam:
	@if [ ! -d $(CERTS_DIR) ] ; then \
		mkdir -m 0777 $(CERTS_DIR); \
	fi

	@if [ ! -f $(CERTS_DIR)/dhparam.pem ]; then \
		openssl dhparam -out $(CERTS_DIR)/dhparam.pem 4096; \
	fi

.PHONY: build # Build and start Docker containers.
build:
	docker-compose \
		--file $(DOCKER_DIR)/docker-compose.yaml \
		--env-file $(ENV_FILE_PATH) up \
		--detach \
		--force-recreate \
		--build

.PHONY: htpass # Create the HTTP basic authentication .htpasswd file.
htpass:
	@if [ ! -d $(BASIC_AUTH_DIR) ]; then \
		mkdir -m 0777 $(BASIC_AUTH_DIR); \
	fi

	@read -r -p "PLEASE ENTER PASSWORD FOR HTTP BASIC AUTHENTICATION: " password; \
	htpasswd -b -cB $(BASIC_AUTH_DIR)/.htpasswd $(HTPASS_USER) "$$password"

.PHONY: status # Display the status of images, volumes, and containers.
status:
	@echo "--------------------------------------------------"
	docker ps -a
	@echo "--------------------------------------------------"
	docker images
	@echo "--------------------------------------------------"
	docker volume ls
	@echo "--------------------------------------------------"
	docker network ls
	@echo "--------------------------------------------------"

.PHONY: exec|c # Execute a shell within a specified container.
exec:
	docker exec -it $(c) sh

.PHONY: logs|c # Display logs for the specified container.
logs:
	docker logs $(c) --tail=50

.PHONY: nginx # Reload the NGINX configuration.
nginx:
	docker exec -it nginx sh -c "nginx -s reload"

.PHONY: restart|c # Restart a specified Docker container.
restart:
	docker-compose \
		--file $(DOCKER_DIR)/docker-compose.yaml \
		--env-file $(ENV_FILE_PATH) restart $(c)