# KoLmafia Container

A Docker container that runs KoLmafia (Kingdom of Loathing client) with a VNC-enabled desktop environment.

## Features

- **KoLmafia Game Client**: Latest version automatically downloaded
- **VNC Desktop**: XFCE desktop environment accessible via VNC
- **Web Interface**: Browser-based VNC client at port 6901
- **Persistence**: KoLmafia data directory is persisted via Docker volumes
- **Auto-updates**: GitHub Actions workflow automatically builds new versions

## Quick Start

### Using GitHub Container Registry (GHCR)
```bash
# Create a volume for persistence
docker volume create kolmafia-data

# Run the container
docker run -d -p 6901:6901 -p 5901:5901 \
  -v kolmafia-data:/home/docker/.kolmafia \
  --name kolmafia ghcr.io/${{ github.repository }}/kolmafia:latest
```

### Using Local Build
```bash
# Build the container
docker build -t kolmafia:v28569 .

# Create a volume for persistence
docker volume create kolmafia-data

# Run the container
docker run -d -p 6901:6901 -p 5901:5901 \
  -v kolmafia-data:/home/docker/.kolmafia \
  --name kolmafia kolmafia:v28569
```

## Access

### Web Interface (Recommended)
Open your browser and go to:
```
http://localhost:6901
```

### Direct VNC
- **Host**: `localhost`
- **Port**: `5901`
- **Password**: `vncpassword`

## Configuration

### Environment Variables
- `VNC_PASSWORD`: Set VNC password (default: `vncpassword`)
- `VERSION`: KoLmafia version to download (default: `28569`)

### Build Arguments
- `VERSION`: KoLmafia version number
- `JAR_URL`: Direct URL to KoLmafia JAR file

Example:
```bash
docker build \
  --build-arg VERSION=28570 \
  --build-arg JAR_URL=https://github.com/kolmafia/kolmafia/releases/download/r28570/KoLmafia-28570.jar \
  -t kolmafia:v28570 .
```

## GitHub Actions Workflow

The repository includes GitHub Actions workflows that automatically:

1. **Check for new KoLmafia releases** daily
2. **Build new container images** when updates are available
3. **Push to GitHub Container Registry (GHCR)**
4. **Create GitHub releases** with usage instructions

### Setup

1. **Fork this repository** to your GitHub account

2. **No secrets required**: The workflow uses the built-in `GITHUB_TOKEN` to push to GHCR

3. **Enable workflows**:
   - Go to Actions tab
   - Enable the workflows

### Workflow Triggers

- **Daily**: Automatically checks for new releases at 2 AM UTC
- **Manual**: Trigger via GitHub Actions UI
- **Push**: Triggers on pushes to main branch

### Available Images

Images are automatically published to GitHub Container Registry at:
```
ghcr.io/your-username/kolmafia:latest
ghcr.io/your-username/kolmafia:v28569
ghcr.io/your-username/kolmafia:v28570
```

## Persistence

The container uses Docker volumes to persist KoLmafia data:

```bash
# Named volume (recommended)
docker volume create kolmafia-data
docker run -v kolmafia-data:/home/docker/.kolmafia ...

# Host directory
docker run -v ~/kolmafia-data:/home/docker/.kolmafia ...
```

## Troubleshooting

### VNC Connection Issues
- Ensure ports 5901 and 6901 are accessible
- Check firewall settings
- Verify the container is running: `docker logs kolmafia`

### KoLmafia Not Starting
- Check container logs: `docker logs kolmafia`
- Verify Java installation: `docker exec kolmafia java -version`
- Check VNC desktop is running: `docker exec kolmafia ps aux | grep xfce`

## License

This project is licensed under the MIT License - see the LICENSE file for details.
