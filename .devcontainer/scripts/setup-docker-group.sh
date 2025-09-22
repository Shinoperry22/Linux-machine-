#!/bin/sh
# Align the container's docker group to the host socket GID and add the user to that group.
set -e
SOCKET=/var/run/docker.sock
USER_NAME=${REMOTE_USER:-devuser}

if [ ! -S "$SOCKET" ]; then
  echo "No docker socket found at $SOCKET, skipping docker group sync."
  exit 0
fi

HOST_GID=$(stat -c '%g' "$SOCKET")

# If a group with that GID exists, use it; otherwise create a 'docker' group with that GID.
EXISTING_GROUP=$(getent group "$HOST_GID" | cut -d: -f1 || true)
if [ -n "$EXISTING_GROUP" ]; then
  DOCKER_GROUP="$EXISTING_GROUP"
else
  DOCKER_GROUP=docker
  if getent group "$DOCKER_GROUP" >/dev/null 2>&1; then
    echo "Group 'docker' exists but with different GID, trying to modify it to match host GID"
    groupmod -g $HOST_GID $DOCKER_GROUP || true
  else
    addgroup -g $HOST_GID $DOCKER_GROUP || true
  fi
fi

# Add user to the docker group
if id "$USER_NAME" >/dev/null 2>&1; then
  addgroup $USER_NAME $DOCKER_GROUP || true
fi

# Set socket ownership to root:docker and permissions to 660
chown root:$DOCKER_GROUP "$SOCKET" || true
chmod 660 "$SOCKET" || true

echo "Docker socket gid set to $HOST_GID and $USER_NAME added to group $DOCKER_GROUP"
