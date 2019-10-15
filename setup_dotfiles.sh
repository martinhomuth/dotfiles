#!/bin/bash

set -x

# this script is used to deploy all dotfiles in this repository. While
# doing so every every placeholder is replaced with the appropriate
# values of the accompanying configuration files

source /usr/include/mh_common.sh || exit 4

# read configuration values based on current branch
BRANCH=$(git branch --show-current)
[ -f configs/${BRANCH} ] || error "Config for branch ${BRANCH} does not exist"
source configs/${BRANCH}

# Xdefaults

FILE=Xdefaults
TGT="${HOME}/.${FILE}"
cp ${FILE} ${TGT}

sed -i "s/\${FONTNAME}/${FONTNAME}/g" ${TGT}
sed -i "s/\${FONTSIZE}/${FONTSIZE}/g" ${TGT}

# i3

FILE=i3wm/config
TGT="${HOME}/.i3/config"
mkdir -pv $(dirname ${TGT})
cp ${FILE} ${TGT}

sed -i "s/\${MAINMONITOR}/${MAINMONITOR}/g" ${TGT}
sed -i "s/\${SECONDARYMONITOR}/${SECONDARYMONITOR}/g" ${TGT}
sed -i "s/\${FONTNAME}/${FONTNAME}/g" ${TGT}
sed -i "s/\${FONTSIZE}/${FONTSIZE}/g" ${TGT}

FILE=i3wm/i3status.conf
TGT="${HOME}/.i3/i3status.conf"
mkdir -pv $(dirname ${TGT})
cp ${FILE} ${TGT}
