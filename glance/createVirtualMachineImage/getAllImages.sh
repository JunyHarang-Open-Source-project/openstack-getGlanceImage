#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
VERSION="1.0.0"
LOG_DIR="/var/log/glance/image/${TODAY}"
LOG_FILE="${LOG_DIR}/getImages.log"
IMAGES_DIR="/root/download/openstack/images"

# -------------------------------------------------------
# SSH Access Web Hook Notification
# Written by: Juny(junyharang8592@gmail.com)
# Last updated on: 2023/10/08
# -------------------------------------------------------

