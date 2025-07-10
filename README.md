# KoLmafia Container

![Build Stats](https://img.shields.io/github/actions/workflow/status/omdv/kolmafia-docker/build-and-push.yml)
[![GHCR Image](https://ghcr-badge.egpl.dev/omdv%2Fkolmafia-docker/kolmafia/tags?color=%2344cc11&ignore=latest%2Cmain&n=1&label=image+tags&trim=)](https://github.com/omdv/kolmafia-docker/packages)
[![GHCR Size](https://ghcr-badge.egpl.dev/omdv%2Fkolmafia-docker/kolmafia/size?color=%2344cc11&tag=latest&label=image+size&trim=)](https://github.com/omdv/kolmafia-docker/packages)


## Description
KoLmafia on-the-go, when you are away from your machine.

- **KoLmafia Game Client**: Latest version automatically downloaded
- **VNC Desktop**: XFCE desktop environment accessible via VNC
- **Web Interface**: Browser-based VNC client at port 6901
- **Persistence**: Keep your configuration safe and persisted.
- **Auto-updates**: GitHub Actions workflow automatically builds new versions


## Quick Start

```bash
docker run -d -p 6901:6901 --name kolmafia ghcr.io/omdv/kolmafia-docker/kolmafia:latest
```
- Open `http://localhost:6901`
- Default password is `vncpassword`,

## Configuration

- `VNC_PW`: Set VNC password (default: `vncpassword`)
- `VNC_COL_DEPTH`: Set VNC color depth (default: 24)
- `VNC_RESOLUTION`: Set VNC resolution (default: 1280x1024)
- `VNC_PASSWORDLESS`: default: <not set>
- Mount `/headless/.kolmafia` to your host folder for persistence


### Available Images

Images are automatically published to GitHub Container Registry at:
```
ghcr.io/your-username/kolmafia:latest
ghcr.io/your-username/kolmafia:v28569
ghcr.io/your-username/kolmafia:v28570
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
