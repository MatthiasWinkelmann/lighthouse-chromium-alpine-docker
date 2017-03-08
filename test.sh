#!/bin/sh

/bin/sh -c "./lighthouse-chromium-xvfb.sh --output-path=/tmp/test-report.html https://matthi.coffee"
grep -q "Best Practices" /tmp/test-report*
