# === BASE STAGE ===

FROM python:3.8 as base

# Install system dependencies
RUN apt-get update
RUN apt-get install pipenv -y

# Set environment variables
ENV appDirectory /app
WORKDIR ${appDirectory}

# Add the dependency manager files
ADD Pipfile ${appDirectory}
ADD Pipfile.lock ${appDirectory}

# Install application dependencies
RUN pipenv install --dev

# === ENTRYPOINT STAGE ===

FROM base as entrypoint

# Command to run when the container start
ENTRYPOINT [ "pipenv", "run", "python", "./src/main.py" ]

# === PRODUCTION BUILD STAGE ===

FROM entrypoint as production

# Add the application source files
ADD ./src/* ${appDirectory}/src/
