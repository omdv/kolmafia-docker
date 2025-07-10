# Start with a VNC image that has browser support
FROM consol/debian-xfce-vnc:latest

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments for dynamic versioning (moved to end for layer optimization)
ARG VERSION=28569
ARG JAR_URL=https://github.com/kolmafia/kolmafia/releases/download/r28569/KoLmafia-28569.jar

# Install Java and other KoLmafia-specific dependencies
USER 0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        gnupg && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        temurin-21-jdk \
        supervisor \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Customizations for your Java App ---
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV APP_DIR=/opt/kolmafia

# Create a directory for your application with proper permissions
RUN mkdir -p $APP_DIR && chmod 755 $APP_DIR && chown 1000:1000 $APP_DIR

# Create supervisord directories and set permissions
RUN mkdir -p /var/log/supervisor /var/run/supervisor && \
    chown -R 1000:1000 /var/log/supervisor /var/run/supervisor

# Configure Supervisor to manage your Java app
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Create KoLmafia data directory and set it as a volume for persistence
RUN mkdir -p /headless/.kolmafia && chown 1000:1000 /headless/.kolmafia

# Add labels for better container management
LABEL org.opencontainers.image.title="KoLmafia Container"
LABEL org.opencontainers.image.description="KoLmafia game client in a VNC-enabled container"
LABEL org.opencontainers.image.source="https://github.com/kolmafia/kolmafia"
LABEL maintainer="Your Name <your.email@example.com>"

# Copy your JAR file into the container (use build arg for dynamic versioning)
# This is moved to the end to optimize layer caching
RUN wget $JAR_URL -O $APP_DIR/kolmafia.jar && \
    chown 1000:1000 $APP_DIR/kolmafia.jar

# Add version-specific label at the end to optimize layer caching
LABEL org.opencontainers.image.version="$VERSION"

# Switch back to default user
USER 1000

# Command to run when the container starts (run as user 1000 to match ConSol image)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
