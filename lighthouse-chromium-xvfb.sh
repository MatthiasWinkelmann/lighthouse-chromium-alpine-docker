#!/bin/sh

_kill_procs() {
  kill -TERM $chromium
  wait $chromium
  kill -TERM $xvfb
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

XVFB_WHD=${XVFB_WHD:-1280x720x16}

export DISPLAY=:99


# Start Xvfb
dbus-run-session -- Xvfb :99 -ac -screen 0 $XVFB_WHD -nolisten tcp &

xvfb=$!

while [  1 -gt $xvfb  ]; do echo "waiting for Xvfb to start: $xvfb"; sleep 1; done

echo "xvfb started"


dbus-run-session -- /usr/bin/chromium-browser --no-sandbox --user-data-dir=$TMP_PROFILE_DIR --start-maximized --no-first-run --remote-debugging-port=9222 "about:blank" &

chromium=$!

while [ 1 -gt $chromium ]; do echo "waiting for chromium to start"; sleep 1; done

echo "chromium started"

lighthouse --port=9222 --disable-webgl --skip-autolaunch --disable-cpu-throttling=true $@
