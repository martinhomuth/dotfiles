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


