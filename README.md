# lighthouse/chromium/alpine/docker image

**Run Google's Lighthouse headless in the background**

This image allows you to quickly run [lighthouse](https://github.com/GoogleChrome/lighthouse) in a headless container. That's useful if you want to run it from a CI server, or in the background of your workstation.

To install:

```shell
    git clone git@github.com:MatthiasWinkelmann/lighthouse-chromium-alpine-docker.git
    docker build -t lighthouse-chromium-alpine-docker
```

Processes within the container cannot easily access the host's file system. You can either print to STDOUT and redirect to a file, or mount a local folder in the container, as shown here:

```shell
 run -v  ./output/:/lighthouse/output/ lighthouse-chromium-alpine-docker --output-path=/lighthouse/output/results.html --save-assets --save-artifacts --output=html https://google.com
```

Run the tesT:

```shell
docker run -it --rm --entrypoint=sh lighthouse test.sh
```
