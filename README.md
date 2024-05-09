# LEPP Environment Docker Configuration

This Docker setup provides a LEPP (Linux, NGINX, PostgreSQL, PHP) stack configured for optimal performance. Below are the details of the services included in this environment:

- **NGINX** v1.26.0-alpine3.19, with added support for gzip compression, SSL, Diffie-Hellman parameter customization, and various optimizations.
- **PostgreSQL** v16.2-alpine3.19, ready for robust database management.
- **PHP** v8.3.6-fpm-alpine3.19, set up to work seamlessly with NGINX.

## Available Commands

Utilize the `make` utility to manage your Docker environment:

- **`make help`** - Lists all available commands.
- **`make hard`** - Starts the project with a clean state, removing all existing Docker containers and volumes.
- **`make start`** - Builds the project and sets up all required services.
- **`make htpass`** - Adds basic HTTP authentication. Execute this after `make hard`.

### Quick Start

- To explore all commands, run the following in your terminal: `make help`
- To automatically set up the entire environment, simply execute: `make start`
- Once the setup is complete, you can access your local server via: [https://localhost](https://localhost)

---
> **Important Note**: The command `make start` will clear all existing containers and volumes. Ensure you have backups if necessary.
---

**Developed and maintained by Aleksandar Rakić -**
**[Email](mailto:aleksandar.rakic@yahoo.com)** /
**[LinkedIn](https://www.linkedin.com/in/rakic-aleksandar)** /
**[GitHub](https://github.com/atco89)**