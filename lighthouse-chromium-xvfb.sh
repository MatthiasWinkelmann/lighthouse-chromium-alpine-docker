#!/bin/sh

_kill_procs() {
  kill -TERM $chromium
  wait $chromium
  kill -TERM $xvfb
}

/usr/bin/dbus-uuidgen --ensure=/etc/machine-id

# We need to test if /var/run/dbus exists, since script will fail if it does not

[ ! -e /var/run/dbus ] && mkdir /var/run/dbus

start-stop-daemon --start --pidfile /var/run/dbus.pid --exec /usr/bin/dbus-daemon -- --system

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

TMP_PROFILE_DIR=`mktemp -d -t chromium.XXXXXX`
CHROME_DEBUGGING_PORT=9222

# Start Xvfb
Xvfb ${DISPLAY} -ac -screen 0 ${GEOMETRY} -nolisten tcp &

xvfb=$!

while [  1 -gt $xvfb  ]; do echo "waiting for Xvfb to start: $xvfb"; sleep 1; done

echo "xvfb started"

echo "Starting chromium, with debugger on port $CHROME_DEBUGGING_POST"
/usr/bin/chromium-browser \
--no-sandbox \
--user-data-dir=${TMP_PROFILE_DIR}  \
--disable-webgl \
--start-maximized \
--remote-debugging-port=${CHROME_DEBUGGING_PORT} \
--no-first-run "about:blank" &

chromium=$!

wait4ports tcp://127.0.0.1:$CHROME_DEBUGGING_PORT

echo "chromium started"

lighthouse --port=${CHROME_DEBUGGING_PORT} \
   --skip-autolaunch \
   --disable-cpu-throttling=true $@
