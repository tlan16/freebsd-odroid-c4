FROM debian:stable-slim

# Quick debug image to verify 32-bit loader is installed
RUN dpkg --add-architecture i386 \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends libc6:i386 libncurses5:i386 libstdc++6:i386 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Default command prints loader location and drops to a shell for inspection
CMD ls -l /lib/ld-linux.so.2 /lib/i386-linux-gnu/ld-linux.so.2 2>/dev/null || true && bash
