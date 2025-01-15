#!/bin/bash -p
# see: https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html#//apple_ref/doc/uid/TP40004268-CH8-SW29

# EMBA - EMBEDDED LINUX ANALYZER
#
# Copyright 2024-2025 Siemens Energy AG
#
# EMBA comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# EMBA is licensed under GPLv3
#
# Author(s): Michael Messner

# Description:  This script automatically downloads the EPSS data from FIRST and generated a csv for further processing
#

FIRST_URL="https://api.first.org/data/v1/epss?envelope=true&pretty=true&offset="
TMP_PATH="./EPSS_temp"
SAVE_PATH="./EPSS_CVE_data"

[[ ! -d "${SAVE_PATH}" ]] && mkdir "${SAVE_PATH}"
[[ -d "${TMP_PATH}" ]] && rm -r "${TMP_PATH}"
[[ ! -d "${TMP_PATH}" ]] && mkdir "${TMP_PATH}"

rm "${SAVE_PATH}"/CVE_*_EPSS.csv || true

CNT=0
while(true); do
  echo "[*] Downloading EPSS offset ${CNT}"

  curl "${FIRST_URL}""${CNT}" > "${TMP_PATH}"/EPSS-"${CNT}".json

  if [[ "$(jq '.data' "${TMP_PATH}"/EPSS-"${CNT}".json | wc -l)" -eq 1 ]]; then
    echo "[*] Stop downloading EPSS with offset ${CNT}"
    break
  fi

  echo "[*] Processing EPSS data ... CNT ${CNT}"

  for i in {0..99}; do
    CVE_ID=$(jq -r ".data[${i}].cve" "${TMP_PATH}"/EPSS-"${CNT}".json || (echo "[-] Error in processing ${TMP_PATH}/EPSS-${CNT}.json"))
    EPSS=$(jq -r ".data[${i}].epss" "${TMP_PATH}"/EPSS-"${CNT}".json || (echo "[-] Error in processing ${TMP_PATH}/EPSS-${CNT}.json"))
    PERC=$(jq -r ".data[${i}].percentile" "${TMP_PATH}"/EPSS-"${CNT}".json || (echo "[-] Error in processing ${TMP_PATH}/EPSS-${CNT}.json"))

    echo "[*] Processing EPSS data ... ${CVE_ID}"

    CVE_YEAR="$(echo "${CVE_ID}" | cut -d '-' -f2)"
    [[ ! "${CVE_YEAR}" =~ ^[0-9]+$ ]] && continue

    echo "${CVE_ID:-NA};${EPSS:-NA};${PERC:-NA}" >> "${SAVE_PATH}"/"CVE_${CVE_YEAR}_EPSS.csv" || (echo "[-] Error in processing CVE entry ${CVE_ID} from ${TMP_PATH}/EPSS-${CNT}.json")
  done
  CNT=$((CNT+100))
done

[[ -d "${TMP_PATH}" ]] && rm -r "${TMP_PATH}"
