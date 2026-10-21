#!/bin/sh
# Trust the system CAs plus the local proxy's CA (it re-signs uat2 only), then serve through the proxy.
set -e
for i in $(seq 1 30); do [ -f /certs/mitmproxy-ca-cert.pem ] && break; sleep 1; done
cat /etc/ssl/certs/ca-certificates.crt /certs/mitmproxy-ca-cert.pem > /tmp/ca.pem
exec moli serve --host 0.0.0.0 --port 9222 --layout --http-proxy http://proxy:8080 --ca-cert /tmp/ca.pem
