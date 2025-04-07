This Bash script automates the installation and configuration of two Dockerized applications: litellm and open-webui. Here's an overview of what the script does:

Prerequisite Checks:

It begins by verifying that essential commands (git, docker, and docker-compose) are installed. If any are missing, the script will exit with an error message.

litellm Setup:

Repository Handling: The script checks if the litellm directory already exists. If it does, the script pulls the latest changes from the repository; if not, it clones the repository from GitHub.

Environment Configuration:

The script prompts the user for two secret key inputs (without the prefix sk-).

It automatically prepends sk- to these inputs and creates a .env file with the variables LITELLM_MASTER_KEY and LITELLM_SALT_KEY.

The content of the .env file is displayed for the user to review and copy if necessary.

Application Startup: It uses docker-compose up -d to start the litellm application.

open-webui Setup:

Repository Handling: Similar to litellm, the script checks for an existing open-webui directory and either updates it or clones it from GitHub.

User Input for Customization:

The user is prompted to specify a custom volume mount path (or to accept the default).

The user is also asked to provide a host port for the open-webui container (default is 3000).

Container Launch: The script then runs the open-webui Docker container using the provided volume mount and host port options.

Displaying Access Information:

The script retrieves the machine’s IP address and prints the URLs for accessing both applications (litellm on port 4000 and open-webui on the chosen host port).

Finally, it lists all running Docker containers using docker ps to provide a confirmation of the running services.

Additional Features and Improvements:

The script includes user-friendly prompts, error checking, and flexibility in configuring host ports and volume mounts.

Suggestions for further improvements include adding input validation, automatically detecting in-use ports, and backing up existing configuration files before making changes.

This automation helps streamline the setup process by reducing manual steps and ensuring that both applications are properly configured and running in Docker containers.
