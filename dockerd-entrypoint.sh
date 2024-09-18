
#!/bin/bash

# Start the Docker daemon
dockerd &

# Wait for Docker daemon to start
while (! docker stats --no-stream ); do
    echo "Waiting for Docker to launch..."
    sleep 1
done

# Now execute the passed command
exec "$@"
