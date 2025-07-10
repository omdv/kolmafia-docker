# Start with a more recent Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments for dynamic versioning
ARG VERSION=28569
ARG JAR_URL=https://github.com/kolmafia/kolmafia/releases/download/r28569/KoLmafia-28569.jar

# Install essential packages, XFCE, and VNC server
# Temporarily switch to root for installations
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        locales \
        wget \
        nano \
        xterm \
        xfce4 \
        xfce4-goodies \
        tightvncserver \
        novnc \
        websockify \
        openjdk-21-jdk \
        supervisor \
        xvfb \
        x11-utils \
        x11-apps \
        dbus-x11 \
        fonts-liberation \
        fonts-dejavu \
        xfonts-base \
        xfonts-100dpi \
        xfonts-75dpi \
        xfonts-cyrillic && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create docker user and setup VNC
RUN useradd -ms /bin/bash docker && \
    mkdir -p /home/docker/.vnc && \
    chown -R docker:docker /home/docker

# Setup VNC user and password (you can set a random password or pass it as build arg)
ARG VNC_PASSWORD=vncpassword
RUN echo "$VNC_PASSWORD" | vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod 600 /home/docker/.vnc/passwd && \
    chown docker:docker /home/docker/.vnc/passwd

# Create VNC startup script with better desktop initialization
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
export XDG_RUNTIME_DIR=/tmp/runtime-docker\n\
mkdir -p $XDG_RUNTIME_DIR\n\
chmod 700 $XDG_RUNTIME_DIR\n\
xrdb $HOME/.Xresources\n\
xsetroot -solid grey\n\
sleep 2\n\
startxfce4 &\n\
sleep 10\n\
echo "Desktop started successfully"\n\
# Keep the script running\n\
while true; do sleep 1; done' > /home/docker/.vnc/xstartup && \
    chmod +x /home/docker/.vnc/xstartup && \
    chown docker:docker /home/docker/.vnc/xstartup

# Create .Xresources file for better X11 support
RUN echo 'Xft.dpi: 96\nXft.antialias: true' > /home/docker/.Xresources && \
    chown docker:docker /home/docker/.Xresources

# Create index.html for noVNC web interface
RUN echo '<!DOCTYPE html>\n\
<html>\n\
<head>\n\
    <title>KoLmafia VNC</title>\n\
    <meta http-equiv="refresh" content="0; url=vnc_lite.html">\n\
</head>\n\
<body>\n\
    <p>Redirecting to VNC client...</p>\n\
    <p><a href="vnc_lite.html">Click here if not redirected automatically</a></p>\n\
</body>\n\
</html>' > /usr/share/novnc/index.html

# --- Customizations for your Java App ---
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
ENV APP_DIR=/opt/kolmafia

# Create a directory for your application with proper permissions
RUN mkdir -p $APP_DIR && chmod 755 $APP_DIR && chown docker:docker $APP_DIR

# Copy your JAR file into the container (use build arg for dynamic versioning)
RUN wget $JAR_URL -O $APP_DIR/kolmafia.jar && \
    chown docker:docker $APP_DIR/kolmafia.jar

# Create supervisord directories and set permissions
RUN mkdir -p /var/log/supervisor /var/run/supervisor && \
    chown -R docker:docker /var/log/supervisor /var/run/supervisor

# Configure Supervisor to manage VNC, noVNC, and your Java app
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Create KoLmafia data directory and set it as a volume for persistence
RUN mkdir -p /home/docker/.kolmafia && chown docker:docker /home/docker/.kolmafia
VOLUME ["/home/docker/.kolmafia"]

# Expose the VNC port (5901) and the noVNC web port (6901)
EXPOSE 5901
EXPOSE 6901

# Default VNC display (important for noVNC)
ENV DISPLAY=:1

# Add labels for better container management
LABEL org.opencontainers.image.title="KoLmafia Container"
LABEL org.opencontainers.image.description="KoLmafia game client in a VNC-enabled container"
LABEL org.opencontainers.image.version="$VERSION"
LABEL org.opencontainers.image.source="https://github.com/kolmafia/kolmafia"
LABEL maintainer="Your Name <your.email@example.com>"

# Command to run when the container starts (run as root to manage services)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
