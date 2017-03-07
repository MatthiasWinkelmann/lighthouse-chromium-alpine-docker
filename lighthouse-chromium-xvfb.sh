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
Xvfb :99 -ac -screen 0 $XVFB_WHD -nolisten tcp &

xvfb=$!




/usr/bin/chromium-browser --no-sandbox --user-data-dir=$TMP_PROFILE_DIR --start-maximized --no-first-run --remote-debugging-port=9222 "about:blank" &

chromium=$!

echo $@
lighthouse $@
