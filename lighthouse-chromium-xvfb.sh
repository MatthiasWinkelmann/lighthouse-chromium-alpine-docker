#!/bin/sh

_kill_procs() {
  kill -TERM $chromium
  wait $chromium
  kill -TERM $xvfb
}

testing=0
echo $@ | grep -q -F 'matthi.coffee' && testing=1;
if [ "$testing" -eq "1" ]; then
   printf "\n\nNo options given, running test...\n\nRun with an URL, or '--help' to see options\n\n";
fi

# We need to test if /var/run/dbus exists, since script will fail if it does not

[ ! -e /var/run/dbus ] && mkdir /var/run/dbus

start-stop-daemon --start --pidfile /var/run/dbus.pid --exec /usr/bin/dbus-daemon -- --system

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

TMP_PROFILE_DIR=`mktemp -d -t chromium.XXXXXX`
export CHROME_DEBUGGING_PORT=9222

# Start Xvfb
Xvfb ${DISPLAY} -ac -screen 0 ${GEOMETRY} -nolisten tcp &

xvfb=$!

printf "Starting xvfb window server"

while [  1 -gt $xvfb  ]; do printf "waiting for Xvfb to start: $xvfb"; sleep 1; done

printf "xvfb started"

printf "Starting chromium, with debugger on port $CHROME_DEBUGGING_POST"

$LIGHTHOUSE_CHROMIUM_PATH \
--no-sandbox \
--user-data-dir=${TMP_PROFILE_DIR}  \
--disable-webgl \
--start-maximized \
--remote-debugging-port=${CHROME_DEBUGGING_PORT} \
--no-first-run "about:blank" &

chromium=$!

wait4ports tcp://127.0.0.1:$CHROME_DEBUGGING_PORT

printf "chromium started"

printf "launching lighthouse run"
lighthouse $@

if [ "$testing" -eq "1" ]; then
   if grep -q -F "Best Practice" /tmp/test-report*; then
      printf "Test succeeded!";
      return 0;
   fi

   printf "Test failed!";
   return 1;
fi
