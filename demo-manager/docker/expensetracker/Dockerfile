# Stage 1: Build the ExpenseTracker from source
# Using debian:bookworm to match the Pi's OS (32-bit ARM compatible)
FROM debian:bookworm AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    maven \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/WynandJvR/ExpenseTracker.git .
RUN mvn package -DskipTests

# Stage 2: Runtime image with virtual display + noVNC
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre \
    openjfx \
    libopenjfx-java \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    libpng-dev \
    libjpeg-dev \
    libgtk-3-0 \
    libgl1 \
    libx11-6 \
    libxtst6 \
    libxrender1 \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy built application from builder stage
WORKDIR /app
COPY --from=builder /build/target/ /app/target/
COPY --from=builder /build/pom.xml /app/pom.xml

# Copy startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Create app data directory
RUN mkdir -p /root/.expenseTracker

EXPOSE 6080

HEALTHCHECK --interval=3s --timeout=3s --retries=10 \
    CMD curl -f http://localhost:6080/ || exit 1

CMD ["/startup.sh"]
