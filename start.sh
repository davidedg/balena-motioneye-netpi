#!/bin/bash


# Copy default configuration if doesn't exists
CONFIG=/etc/motioneye/motioneye.conf
test -e "${CONFIG}" || cp /usr/share/motioneye/extra/motioneye.conf.sample "${CONFIG}"

# Copy default camera_actions script if it does not exist
CAMERA_ACTIONS=/etc/motioneye/camera_actions
test -e "${CAMERA_ACTIONS}" || ( cp /usr/share/motioneye/extra/camera_actions ${CAMERA_ACTIONS} && chmod +x ${CAMERA_ACTIONS} )
# and update the camera actions symlynks if the provided camera action script is executable
[[ -x ${CAMERA_ACTIONS} ]] && bash /update_camera_actions.sh

# Set the server name
if [ -n "${SERVER_NAME}" ]; then
    MEYE_SERVER_NAME="${SERVER_NAME}"
else
    MEYE_SERVER_NAME="${RESIN_DEVICE_NAME_AT_INIT}"
fi
grep -q "^server_name " ${CONFIG} && sed "s/^server_name.*$/server_name ${MEYE_SERVER_NAME}/" -i $CONFIG ||
    sed "$ a\server_name ${MEYE_SERVER_NAME}" -i $CONFIG

grep -q "^port " ${CONFIG} && sed "s/^port .*$/port ${MEYE_PORT}/" -i $CONFIG ||
    sed "$ a\port ${MEYE_PORT}" -i $CONFIG


if [ -n "${TIMEZONE}" ]; then
    echo "Setting timezone: ${TIMEZONE}"
    echo "$TIMEZONE" > /etc/timezone
    rm /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
fi

# Start Avahi
/usr/sbin/avahi-daemon -s &

# Start MotionEye server
/usr/local/bin/meyectl startserver -c /etc/motioneye/motioneye.conf
