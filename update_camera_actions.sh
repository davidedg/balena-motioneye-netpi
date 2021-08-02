#!/bin/bash

CONFIGDIR=/etc/motioneye
CONFIGFILE=motion.conf

if ! [[ -r ${CONFIGDIR}/${CONFIGFILE} ]]; then
    echo "Cannot read ${CONFIGDIR}/${CONFIGFILE}"
    exit 0
fi

ACTIONS=("monitor" "alarm_on" "alarm_off")
ACTIONSCRIPT=camera_actions

cameras=$(grep -c -E "^camera camera-[0-9]+.conf$" ${CONFIGDIR}/${CONFIGFILE} 2>/dev/null)

[[ -n "$cameras" ]] && [[ "$cameras" -gt 0 ]] 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "No camera definitions found in ${CONFIGDIR}/${CONFIGFILE}"
    exit 0
fi

pushd $CONFIGDIR >/dev/null 2>/dev/null
for action in ${ACTIONS[@]}; do
    for (( cid=1; cid<=$cameras; cid++ )); do
        symlink="${action}_${cid}"
        if ! [[ -L $symlink ]]; then
            echo "${symlink} does not exist - creating"
            ln -s ${ACTIONSCRIPT} ${symlink}
        fi
    done
done
popd >/dev/null 2>/dev/null
