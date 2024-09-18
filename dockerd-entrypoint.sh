#!/bin/bash

# Start the Docker daemon in the background
dockerd &

# Wait for Docker daemon to be ready
while (! docker stats --no-stream ); do
    echo "Waiting for Docker to launch..."
    sleep 1
done

# Run 'make all' first
make all

# Run 'make rootfs' with auto input of "2" using expect
/usr/bin/expect <<EOF
spawn make rootfs
expect "Choose an option"
send "2\r"
expect eof
EOF

# Continue to execute the passed commands
exec "$@"
