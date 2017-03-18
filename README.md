# lighthouse/chromium/alpine/docker image

**Run Google's Lighthouse headless in the background**

This image allows you to quickly run [lighthouse](https://github.com/GoogleChrome/lighthouse) in a headless container. That's useful if you want to run it from a CI server, or in the background of your workstation.

## Installation

### From Github

Github URL: <https://github.com/MatthiasWinkelmann/lighthouse-chromium-alpine-docker>

```shell
    git clone git@github.com:MatthiasWinkelmann/lighthouse-chromium-alpine-docker.git
    docker build -t lighthouse lighthouse-chromium-alpine-docker
```

### From Docker Hub

Docker Hub URL: <https://hub.docker.com/r/matthiaswinkelmann/lighthouse-chromium-alpine/>

```shell
docker pull matthiaswinkelmann/lighthouse-chromium-alpine
```

## Usage

Processes within the container cannot easily access the host's file system. You can either print to STDOUT and redirect to a file, or mount a local folder in the container, as shown here:

### Quickstart: Print to STDOUT

```shell
docker run lighthouse --output-path=stdout https://google.com
```

### Saving to file

```shell
docker run -v ./output/:/lighthouse/output/ lighthouse --output-path=/lighthouse/output/results.html --save-assets --save-artifacts https://google.com
```

## Testing

```shell
docker run lighthouse test
```

## Links

Canonical URL: <https://matthi.coffee/2017/lighthouse-chromium-headless-docker>
