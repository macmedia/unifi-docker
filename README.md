# Unifi-Video


## Instructions for use

### Getting docker

- Download Docker from [here](https://www.docker.com/products/docker#/mac); Install by dragging app to /Applications
- (Optional) Right click on the whale in the top menu bar and select “**Open Kitematic**”, follow the download link and install the app to /Applications

### Unifi-Video installation

Because /usr/local is reserved for Docker, the example demonstrates installation of Unifi Video in a manner where the Host Data Volume directories are located in `~/Applications/unifi-video`. You can change this to your liking.

**NB!** If you receive permission errors when executing commands, precede them with `sudo`

- Create the `~/Applications/unifi-video` directory
    

```
`$ docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
melser/unifi-video   v3.9.3              1cbeb1e369da        44 minutes ago      869.9 MB
```

- (Optional) Download\Save `run.sh` from [here](https://raw.githubusercontent.com/exsilium/docker-unifi-video/v3.8.1/run.sh)
- Create the following host data directories under `~/Applications/unifi-video`
    - `mkdir mongodb`
    - `mkdir unifi-video`
    - `mkdir log`

- Execute `./run.sh -v 2.9.3` to run the container or create the image.

``` 
`Checking for Host data volumes: MongoDB-OK | Unifi-Video-OK | Log-OK
16eeb080627ac648804fd0f9e64dd4569680137989d46c388ea74afb59480440
```

- You should be able to open the Unifi Video setup wizard using Chrome on https://<yourIP>:7443

### Camera provisioning

By default, Docker provides network isolation and due to that the automatic discovery will not work. Directly access your camera IP and enter the host IP of your server where the unifi-video docker image is running.

## Upgrade from 3.x.x to 3.8.1

**NB!** Always create a backup before trying to upgrade!
**NB!** Upgrade scenarios over multiple versions have not been tested!
**NB!** Make sure to read release notes prior to upgrade!
**NB!** Note that, when upgrading to v3.8.1, a new port 7442 was added for secure camera communications. Make sure docker maps this new port when starting and that you handle any additional routing settings you may have to that port.


## Need help?

If you have questions, comments, concerns. Did you find something not working or if you just need help, please [file a Github Issue](https://github.com/macmedia/unifi-docker/issues) and I'll do my best to help you.

Please don't use Docker Hub comments section for reaching out!
