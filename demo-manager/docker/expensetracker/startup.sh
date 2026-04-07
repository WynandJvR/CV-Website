#!/bin/bash
set -e

# Start virtual display (1280x800, 24-bit color)
export DISPLAY=:99
Xvfb :99 -screen 0 1280x800x24 -ac +extension GLX +render -noreset &
sleep 1

# Start VNC server (no password, shared mode)
x11vnc -display :99 -forever -nopw -rfbport 5900 -shared -xkb &
sleep 1

# Start noVNC (WebSocket bridge: port 6080 -> VNC port 5900)
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 1

echo "noVNC ready on port 6080"

# Find and launch the ExpenseTracker JAR
JAR_FILE=$(find /app/target -name "*.jar" -not -name "*-sources.jar" -not -name "*-javadoc.jar" | head -1)

if [ -z "$JAR_FILE" ]; then
    echo "ERROR: No JAR file found in /app/target/"
    ls -la /app/target/
    exit 1
fi

echo "Starting ExpenseTracker: $JAR_FILE"

# Run with software rendering fallback for ARM compatibility
exec java \
    -Dprism.order=sw \
    -Dglass.platform=gtk \
    -Djava.awt.headless=false \
    -Dtessdata.prefix=/usr/share/tesseract-ocr/5/tessdata \
    --module-path /usr/share/openjfx/lib \
    --add-modules javafx.controls,javafx.fxml,javafx.graphics \
    -jar "$JAR_FILE"
