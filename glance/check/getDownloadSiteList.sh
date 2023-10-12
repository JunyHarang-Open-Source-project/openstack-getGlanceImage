#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
LOG_DIR="/var/log/openstack/glance/image/check-site/${TODAY}"
LOG_FILE="${LOG_DIR}/getDownloadSiteList.log"
ROOT_PATH=$(pwd)
DOWNLOAD_OS_SITE_LIST_INI_FILE="$ROOT_PATH/check/downloadSiteList.ini"

CENTOS_SITE="https://cloud.centos.org/centos"
FEDORA_37_SITE="https://ftp.riken.jp/Linux/fedora/releases/37/Cloud/x86_64/images/"
FEDORA_38_SITE="https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images"
UBUNTU_SITE="https://cloud-images.ubuntu.com"

# 각 OS에 대한 연관 배열 정의
declare -gA centosSites
declare -gA fedora37Sites
declare -gA fedora38Sites
declare -gA ubuntuSites

licenseNotice() {

  echo "[$ACCESS_DATE] [NOTICE] 해당 Shell Script License에 대한 내용 고지합니다. 숙지하시고, 사용 부탁드립니다."

  echo "[$ACCESS_DATE] [NOTICE] http://opensource.org/licenses/MIT"
  echo "[$ACCESS_DATE] [NOTICE] Copyright (c) 2023 juny(juny8592@gmail.com) Tech Blog: https://junyharang.tistory.com/"
  echo "[$ACCESS_DATE] [NOTICE] Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the \"Software\"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE."

  checkLogRelevant
}

checkLogRelevant() {
  echo "[$ACCESS_DATE] [INFO] Log가 쌓일 Directory가 존재하는지 확인할게요.(check if there is a Directory where the log will stack.)"

  if [ -d "$LOG_DIR" ];
  then
    echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 동작(Open Stack $DOWNLOAD_OS_NAME Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
    echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1

    echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 합니다.(Directory exists for saving the log.)"
    echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 합니다.(Directory exists for saving the log.)" >> "$LOG_FILE" 2>&1
  else
    echo "[$ACCESS_DATE] [INFO] Log가 쌓일 Directory가 존재하지 않아 Directory를 생성할게요.(There is no Directory for the Log to stack, so I will create a Directory.)"
    mkdir -p $LOG_DIR

    if [ $? != 0 ];
    then
      echo "[$ACCESS_DATE] [ERROR] Log 저장을 위한 Directory 만들기 실패 하였습니다.(Failed to create Directory for Log Save.)"

      exit 1
     else
       echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 동작(Open Stack $DOWNLOAD_OS_NAME Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
       echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1

       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)"
       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)" >> "$LOG_FILE" 2>&1
     fi
  fi

  getImageStorageInfo

  searchOsStorage
}

getImageStorageInfo() {
  echo "[$ACCESS_DATE] [DEBUG] 등록된 이미지 저장소 정보를 가져올게요. (I'll get the registered image store information.)" >> "$LOG_FILE" 2>&1

  # downloadSiteList.ini 파일을 읽고 구문 분석
  while IFS='=' read -r key value; do
    # Remove leading/trailing whitespace
    key=${key%%*( )}  # Remove leading whitespace
    key=${key##*( )}  # Remove trailing whitespace
    value=${value%%*( )}
    value=${value##*( )}

    if [[ $key == "centOs"* ]]; then
      centosSites["$key"]="$value"
    elif [[ $key == "fedora37" ]]; then
      fedora37Sites["$key"]="$value"
    elif [[ $key == "fedora38" ]]; then
      fedora38Sites["$key"]="$value"
    elif [[ $key == "ubuntu"* ]]; then
      ubuntuSites["$key"]="$value"
    fi

    echo "[$ACCESS_DATE] [DEBUG] downloadSiteList.ini Key: $key, Value: $value"

  done < "$DOWNLOAD_OS_SITE_LIST_INI_FILE"
}

searchOsStorage() {
  echo "[$ACCESS_DATE] [INFO] 어떤 OS의 저장소 정보를 조회하고 싶어요? 숫자만 입력할 수 있어요.(Which OS's storage information would you like to look up? You can only enter numbers.)"
  echo "[$ACCESS_DATE] [INFO] 어떤 OS의 저장소 정보를 조회하고 싶어요? 숫자만 입력할 수 있어요.(Which OS's storage information would you like to look up? You can only enter numbers.)" >> "$LOG_FILE" 2>&1

  select storageSite in "All Storage" "CentOS" "CirrOS(test)" "Debian" "Fedora37" "Fedora38" "Microsoft Windows" "Ubuntu" "openSUSE and SUSE Linux Enterprise Server" "FreeBSD, OpenBSD, and NetBSD" "Arch Linux" "종료(exit)";
    do
      case $REPLY in
      "1")
        getStorageInfo "CentOS"
        getStorageInfo "Fedora37"
        getStorageInfo "Fedora38"
        getStorageInfo "Ubuntu"
        ;;
      "2")
        getStorageInfo "CentOS";;
      "3")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "4")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "5")
        getStorageInfo "Fedora37";;
      "6")
        getStorageInfo "Fedora38";;
      "7")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "8")
        getStorageInfo "Ubuntu";;
      "9")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "10")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "11")
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
        echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
        ;;
      "12")
        break;;
      *)
        echo "올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      esac
    done
}

getStorageInfo() {
  sleep 1
  local selectedUserOs=$1
  imageDownloadSiteName=""

  checkImageStorageNetworkConnection "$selectedUserOs"

  echo "$selectedUserOs 저장소 URL 목록($selectedUserOs store information): "
  echo "[$ACCESS_DATE] [INFO] $selectedUserOs 저장소 URL 목록($selectedUserOs store information): " 2>&1

  if [[ $selectedUserOs == "CentOS" ]]; then
    for imageDownloadSiteName in "${!centosSites[@]}"; do
      echo "${centosSites[$imageDownloadSiteName]}"
      echo "${centosSites[$imageDownloadSiteName]}" 2>&1
    done
  elif [[ $selectedUserOs == "Fedora37" ]]; then
    for imageDownloadSiteName in "${!fedora37Sites[@]}"; do
      echo "${fedora37Sites[$imageDownloadSiteName]}"
      echo "${fedora37Sites[$imageDownloadSiteName]}" 2>&1
    done
  elif [[ $selectedUserOs == "Fedora38" ]]; then
    for imageDownloadSiteName in "${!fedora38Sites[@]}"; do
      echo "${fedora38Sites[$imageDownloadSiteName]}"
      echo "${fedora38Sites[$imageDownloadSiteName]}" 2>&1
    done
  elif [[ $selectedUserOs == "Ubuntu" ]]; then
    for imageDownloadSiteName in "${!ubuntuSites[@]}"; do
      echo "${ubuntuSites[$imageDownloadSiteName]}"
      echo "${ubuntuSites[$imageDownloadSiteName]}" 2>&1
    done
  else
      echo "등록되지 않은 OS 내려받기 위한 사이트에요.(It's a site for downloading unregistered OS.)"
      echo "[$ACCESS_DATE] [ERROR] 등록되지 않은 OS 내려받기 위한 사이트에요.(It's a site for downloading unregistered OS.)" >> "$LOG_FILE" 2>&1
  fi
}

checkImageStorageNetworkConnection() {
  sleep 1
  selectedUserOs=$1
  checkCurlSiteResult=($(checkCurlSite "$selectedUserOs"))  # 이 부분에서 checkCurlSite 함수를 호출하고 결과를 result 배열에 저장
  networkConnectionResponse="${checkCurlSiteResult[0]}"
  detailNetworkConnectionResponse="${checkCurlSiteResult[1]}"

  echo "$selectedUserOs 저장소 네트워크 통신 가능 여부($selectedUserOs Storage network communications available): $networkConnectionResponse"
  echo "[$ACCESS_DATE] [INFO] $selectedUserOs 저장소 네트워크 통신 가능 여부($selectedUserOs Storage network communications available): $networkConnectionResponse" 2>&1

  if [[ "$networkConnectionResponse" == "200" || "$networkConnectionResponse" == "301" || "$networkConnectionResponse" == "302" ]]; then
    echo "[$ACCESS_DATE] [INFO] 정상 (OK) : $networkConnectionResponse"
    echo "[$ACCESS_DATE] [INFO] 정상 (OK) : $networkConnectionResponse" >> "$LOG_FILE" 2>&1
    echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse"
    echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse" >> "$LOG_FILE" 2>&1

  else
    for index in {0..4}; do
      checkCurlSiteResult=()
      networkConnectionResponse=""
      detailNetworkConnectionResponse=""
      echo "[$ACCESS_DATE] [WARNING] 이미지 저장소 네트워크 확인에 문제가 발생하여 재 확인 시도 할게요.(There is a problem with checking the image storage network, so I will try to double-check.)"
      echo "[$ACCESS_DATE] [WARNING] 이미지 저장소 네트워크 확인에 문제가 발생하여 재 확인 시도 할게요.(There is a problem with checking the image storage network, so I will try to double-check.)" >> "$LOG_FILE" 2>&1
      echo "[$ACCESS_DATE] [WARNING] $index 번째 재시도."
      echo "[$ACCESS_DATE] [WARNING] $index 번째 재시도." "$LOG_FILE" 2>&1

      checkCurlSiteResult=($(checkCurlSite "$selectedUserOs"))  # 이 부분에서 checkCurlSite 함수를 호출하고 결과를 result 배열에 저장
      networkConnectionResponse="${checkCurlSiteResult[0]}"
      detailNetworkConnectionResponse="${checkCurlSiteResult[1]}"

      if [[ "$networkConnectionResponse" == "200" || "$networkConnectionResponse" == "301" || "$networkConnectionResponse" == "302" ]]; then
        echo "[$ACCESS_DATE] [INFO] 정상 (OK) : $networkConnectionResponse"
        echo "[$ACCESS_DATE] [INFO] 정상 (OK) : $networkConnectionResponse" >> "$LOG_FILE" 2>&1
        echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse"
        echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse" >> "$LOG_FILE" 2>&1
        break
      else
        echo "[$ACCESS_DATE] [ERROR] 연결 불가 (Failed): $networkConnectionResponse"
        echo "[$ACCESS_DATE] [ERROR] 연결 불가 (Failed): $networkConnectionResponse" >> "$LOG_FILE" 2>&1
        echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse"
        echo "[$ACCESS_DATE] [INFO] $selectedUserOs 네크워크 연결 상세 정보($selectedUserOs Network Connection Details): $detailNetworkConnectionResponse" >> "$LOG_FILE" 2>&1
      fi
    done
  fi
}

checkCurlSite() {
  sleep 1
  selectedUserOs=$1

  if [[ $selectedUserOs == "CentOS"* ]]; then
    networkConnectionResponse=$(curl -Is "$CENTOS_SITE" | head -n 1 | cut -d ' ' -f 2)
    detailNetworkConnectionResponse=$(curl -Is "$CENTOS_SITE")

  elif [[ $selectedUserOs == "Fedora37"* ]]; then
    networkConnectionResponse=$(curl -Is "$FEDORA_37_SITE" | head -n 1 | cut -d ' ' -f 2)
    detailNetworkConnectionResponse=$(curl -Is "$FEDORA_37_SITE")

  elif [[ $selectedUserOs == "Fedora38"* ]]; then
    networkConnectionResponse=$(curl -Is "$FEDORA_38_SITE" | head -n 1 | cut -d ' ' -f 2)
    detailNetworkConnectionResponse=$(curl -Is "$FEDORA_38_SITE")

  elif [[ $selectedUserOs == "Ubuntu"* ]]; then
    networkConnectionResponse=$(curl -Is "$UBUNTU_SITE" | head -n 1 | cut -d ' ' -f 2)
    detailNetworkConnectionResponse=$(curl -Is "$UBUNTU_SITE")

  else
    echo "[$ACCESS_DATE] [ERROR] 등록되지 않은 OS 내려받기 위한 사이트에요.(It's a site for downloading unregistered OS.)"
    echo "[$ACCESS_DATE] [ERROR] 등록되지 않은 OS 내려받기 위한 사이트에요.(It's a site for downloading unregistered OS.)" >> "$LOG_FILE" 2>&1
  fi

  echo "$networkConnectionResponse"
  echo "$detailNetworkConnectionResponse"
}

echo "==== [$ACCESS_DATE] 오픈스택 내려 받기 위한 이미지 저장소 목록 확인 스크립트 동작(Image store list check script behavior for downloading open stack) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"

licenseNotice

echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"
echo "==== [$ACCESS_DATE] 오픈스택 내려 받기 위한 이미지 저장소 목록 확인 스크립트 끝(Image store list check script behavior for downloading open stack) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/" >> "$LOG_FILE" 2>&1
echo "==== [$ACCESS_DATE] 오픈스택 내려 받기 위한 이미지 저장소 목록 확인 스크립트 끝(Image store list check script behavior for downloading open stack) ===="  >> "$LOG_FILE" 2>&1