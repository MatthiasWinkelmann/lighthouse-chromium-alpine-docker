#!/bin/sh

_kill_procs() {
  kill -TERM $chromium
  wait $chromium
  kill -TERM $xvfb
}

testing=0
parameters=$@

if [ $parameters == 'test' ]; then
   testing=1;
   parameters='--skip-autolaunch --disable-cpu-throttling --output-path=/tmp/test-report.html --output=html https://google.com"'
   printf "\n\nRunning test...\n\nRun with an URL, or '--help' to see options\n\n";
fi

# We need to test if /var/run/dbus exists, since script will fail if it does not

[ ! -e /var/run/dbus ] && mkdir /var/run/dbus

/usr/bin/dbus-daemon --system

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

TMP_PROFILE_DIR=`mktemp -d -t chromium.XXXXXX`
export CHROME_DEBUGGING_PORT=9222

# Start Xvfb
Xvfb ${DISPLAY} -ac +iglx -screen 0 ${GEOMETRY} -nolisten tcp & xvfb=$!

printf "Starting xvfb window server..."

while [  1 -gt $xvfb  ]; do printf "..."; sleep 1; done

printf "xvfb started\n\n"

printf "Starting chromium, with debugger on port $CHROME_DEBUGGING_POST...\n\n"

# --disable-webgl \

$LIGHTHOUSE_CHROMIUM_PATH \
--no-sandbox \
--user-data-dir=${TMP_PROFILE_DIR}  \
--start-maximized \
--remote-debugging-port=${CHROME_DEBUGGING_PORT} \
--no-first-run "about:blank" &

chromium=$!

wait4ports tcp://127.0.0.1:$CHROME_DEBUGGING_PORT

printf "\n\n==============================\nlaunching lighthouse run\n==============================\n\n"

if [ "$testing" -eq "1" ]; then
   lighthouse --skip-autolaunch --disable-cpu-throttling --output-path=/tmp/test-report.html --output=html https://google.com
   if grep -q -F "Best Practice" /tmp/test-report*; then
      printf "\n\n==============================\nTest succeeded!\n==============================\n";
      return 0;
   fi

   printf "\n\n==============================\nTest failed!\n==============================\n";
   return 1;
else
   lighthouse $@
fi
