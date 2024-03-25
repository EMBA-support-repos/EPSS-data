#!/bin/bash -p
# see: https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html#//apple_ref/doc/uid/TP40004268-CH8-SW29

# EMBA - EMBEDDED LINUX ANALYZER
#
# Copyright 2024-2024 Siemens Energy AG
#
# EMBA comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# EMBA is licensed under GPLv3
#
# Author(s): Michael Messner

# Description:  This script automatically downloads the EPSS data from FIRST
#

FIRST_URL="https://api.first.org/data/v1/epss?envelope=true&pretty=true&offset="
SAVE_PATH="./EPSS_downloaded"

[[ ! -d "${SAVE_PATH}" ]] && mkdir "${SAVE_PATH}"

CNT=0
while(true); do
  echo "[*] Downloading EPSS offset ${CNT}"
  curl "${FIRST_URL}""${CNT}" > "${SAVE_PATH}"/EPSS-"${CNT}".json
  if [[ "$(jq '.data' "${SAVE_PATH}"/EPSS-"${CNT}".json | wc -l)" -eq 1 ]]; then
    echo "[*] Stop downloading EPSS with offset ${CNT}"
    break
  fi
  CNT=$((CNT+100))
done
