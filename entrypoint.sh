#!/bin/sh

set -x

PUID=${PUID:-1000}
PGID=${PGID:-1000}
UMASK=${UMASK:-0027}
FIX_PERMISSIONS=${FIX_PERMISSIONS:-true}

JAVA_VM_OPTS=${JAVA_VM_OPTS:-"-Xmx1g -XX:MaxMetaspaceSize=250m"}
YOUTRACK_LISTEN_URL=${YOUTRACK_LISTEN_URL:-"0.0.0.0:8080"}

USER=youtrack
HOME_DIR=/var/youtrack
DATA_DIR="$HOME_DIR/data"
BACKUP_DIR="$HOME_DIR/backup"

# Create user and group
id -u $USER >/dev/null 2>&1 || useradd -u $PUID -U -d $HOME_DIR --no-create-home -s /bin/false $USER

# UID/GID check
CUR_UID=$(getent passwd $USER | cut -f3 -d: || true)
CUR_GID=$(getent group $USER | cut -f3 -d: || true)

if [ "$PUID" != "$CUR_UID" ]; then
    # Change user id
    usermod -o -u "$PUID" $USER
fi

if [ "$PGID" != "$CUR_GID" ]; then
    # Change group id
    groupmod -o -g "$PGID" $USER
fi

# Fix permissions
if [ "$FIX_PERMISSIONS" == "true" ]; then
    chown -R $PUID:$PGID $HOME_DIR
fi

GOSU="/usr/bin/gosu $PUID:$PGID"

umask $UMASK

exec $GOSU /sbin/tini -- /usr/bin/java \
    $JAVA_VM_OPTS \
    -Djava.awt.headless=true \
    -Duser.home=$HOME_DIR \
    -Ddatabase.location=$DATA_DIR \
    -Ddatabase.backup.location=$BACKUP_DIR \
    -Djetbrains.youtrack.disableBrowser=true \
    -Djetbrains.youtrack.enableGuest=false \
    -Djetbrains.youtrack.disableCheckForUpdate=true \
    -Djava.security.egd=/dev/urandom \
    -jar /opt/youtrack/youtrack.jar $YOUTRACK_LISTEN_URL
