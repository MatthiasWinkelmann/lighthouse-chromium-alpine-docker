FROM mhart/alpine-node:latest
LABEL version="1.0"
LABEL description="Run Google Chrome's Lighthouse Audit in the background"
WORKDIR /lighthouse

USER root

RUN echo "http://dl-2.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-2.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

#-----------------
# Add packages
#-----------------
RUN apk -U --no-cache upgrade && \
    apk --no-cache add xvfb\
        dbus-x11\
        libx11\
        xorg-server\
        chromium\
        ttf-opensans
#-----------------
# Set ENV and change mode
#-----------------
ENV LIGHTHOUSE_CHROMIUM_PATH /usr/bin/chromium-browser

ENV TZ "Europe/Berlin"
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99
#:99.0
ENV GEOMETRY "$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

RUN echo $TZ > /etc/timezone

ADD lighthouse-chromium-xvfb.sh .
RUN npm --global install yarn && yarn global add lighthouse
RUN mkdir output

# Minimize size

RUN apk del --force curl make gcc g++ python linux-headers binutils-gold gnupg

RUN rm -rf /var/lib/apt/lists/* \
    /var/cache/* \
    /usr/share/man \
    /tmp/* \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html \
    /usr/lib/node_modules/npm/scripts


ENTRYPOINT ["/lighthouse/lighthouse-chromium-xvfb.sh"]
