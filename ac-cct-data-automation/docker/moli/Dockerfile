# Moli v1.1.18 headless browser, serving CDP on 9222. The release tarball is downloaded on the host and
# checked against GitHub's published sha256 before it gets here (see README.md); the build needs no network
# beyond the base image.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates fontconfig fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
ADD moli-linux.tar.gz /opt/
RUN ln -s /opt/moli-v1.1.18-x86_64-unknown-linux-gnu/moli /usr/local/bin/moli && moli --version
EXPOSE 9222
# --layout: real geometry and screenshots (the evidence's "chat as seen")
ENTRYPOINT ["moli", "serve", "--host", "0.0.0.0", "--port", "9222", "--layout"]
