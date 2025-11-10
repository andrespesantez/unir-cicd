FROM jenkins/jenkins:lts

USER root

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Dar permisos al usuario jenkins para usar Docker
RUN usermod -aG docker jenkins

# Instalar Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

USER jenkins

# Instalar plugins de Jenkins automáticamente
RUN jenkins-plugin-cli --plugins \
    git \
    workflow-aggregator \
    docker-workflow \
    docker-plugin \
    blueocean \
    email-ext \
    junit \
    ssh-agent \
    ssh-slaves \
    pipeline-stage-view \
    copyartifact \
    timestamper \
    ws-cleanup \
    credentials-binding \
    ansicolor

# Saltar el wizard de configuración inicial
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Exponer puertos
EXPOSE 8080 50000
