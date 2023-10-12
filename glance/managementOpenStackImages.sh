#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
SCRIPT_VERSION="1.0.0"
LOG_DIR="/var/log/openstack/glance/image/${TODAY}"
LOG_FILE="${LOG_DIR}/getImages.log"
IMAGES_DIR="/root/download/openstack/images"
ROOT_PATH=$(pwd)

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

  checkWho
}

checkWho() {
  echo "[$ACCESS_DATE] [INFO] 쉘 스크립트 기동 사용자가 root 인지 확인합니다.(Verify that the shell script startup user is root.)"

  if [[ $EUID -ne 0 ]]; then
      echo "[$ACCESS_DATE] [ERROR] 해당 쉘 스크립트는 root로 실행되어야 사용할 수 있어요.(The shell script must run as root before it can be used.)"
      exit 1

  else
      echo "[$NOW] [INFO] 쉘 스크립트가 root로 기동 되었어요.(Shell script started as root.)"
  fi

  checkLogRelevant
}

checkLogRelevant() {
  echo "[$ACCESS_DATE] [INFO] Log가 쌓일 Directory가 존재하는지 확인할게요.(check if there is a Directory where the log will stack.)"

  if [ -d "$LOG_DIR" ];
  then
    echo "==== [$ACCESS_DATE] 오픈스택 이미지 내려받기 스크립트 동작(Open Stack Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
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
       echo "==== [$ACCESS_DATE] 오픈스택 이미지 내려받기 스크립트 동작(Open Stack Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
       echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1

       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)"
       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)" >> "$LOG_FILE" 2>&1
     fi
  fi

  checkRequiredPackages
}

checkRequiredPackages() {
  echo "[$ACCESS_DATE] [INFO] 스크립트 작동에 필요한 wget 패키지가 설치 되어 있는지 확인할게요.(check if the wget package is installed for script operation.)"
  echo "[$ACCESS_DATE] [INFO] 스크립트 작동에 필요한 wget 패키지가 설치 되어 있는지 확인할게요.(check if the wget package is installed for script operation.)" >> "$LOG_FILE" 2>&1

  if [[ -e /etc/os-release ]]; then
      source /etc/os-release
      OS_NAME=$ID
  else
      echo "[$ACCESS_DATE] [ERROR] OS 정보를 찾을 수 없습니다.(No OS information found.)"
      echo "[$ACCESS_DATE] [ERROR] OS 정보를 찾을 수 없습니다.(No OS information found.)" >> "$LOG_FILE" 2>&1

  fi

  if command -v wget &>/dev/null;
  then
    echo "[$ACCESS_DATE] [INFO] wget 패키지가 이미 설치되어 있습니다."
    echo "[$ACCESS_DATE] [INFO] wget 패키지가 이미 설치되어 있습니다." >> "$LOG_FILE" 2>&1

  else
    case "$OS_NAME" in
        "centos" | "fedora")
            sudo yum install -y wget
            ;;
        "debian" | "ubuntu")
            sudo apt-get update
            sudo apt-get install -y wget
            ;;
        *)
            echo "[$ACCESS_DATE] [ERROR] 이 OS에서는 wget 패키지를 설치하는 방법을 지원하지 않습니다.(This OS does not support installing the wget package.)"
            echo "[$ACCESS_DATE] [ERROR] 이 OS에서는 wget 패키지를 설치하는 방법을 지원하지 않습니다.(This OS does not support installing the wget package.)" >> "$LOG_FILE" 2>&1
            exit 1
            ;;
    esac
fi

checkKeystoneAuthorizedValidateToken
}

checkKeystoneAuthorizedValidateToken() {
  echo "[$ACCESS_DATE] [INFO] Keystone 인증 상태를 확인합니다.(Check Keystone authentication status.)"
  echo "[$ACCESS_DATE] [INFO] Keystone 인증 상태를 확인합니다.(Check Keystone authentication status.)" >> "$LOG_FILE" 2>&1

  tokenInfo=$(openstack token issue 2>&1)

  # Keystone 토큰 검증 결과 확인
  if [[ "$tokenInfo" == *"Invalid"* || "$tokenInfo" == *"Unauthorized"* ]]; then
    echo "[$ACCESS_DATE] [ERROR] Keystone 인증이 만료되었거나 유효하지 않습니다.(Keystone authentication has expired or is invalid.)"
    echo "[$ACCESS_DATE] [ERROR] Keystone 인증이 만료되었거나 유효하지 않습니다.(Keystone authentication has expired or is invalid.)"  >> "$LOG_FILE" 2>&1
    echo "[$ACCESS_DATE] [ERROR] $tokenInfo"
    echo "[$ACCESS_DATE] [ERROR] $tokenInfo" >> "$LOG_FILE" 2>&1

    askForLoginKeystone
  else
    echo "[$ACCESS_DATE] [INFO] Keystone 인증이 현재 로그인된 상태입니다.(Keystone authentication is currently logged in.)"
    echo "[$ACCESS_DATE] [INFO] Keystone 인증이 현재 로그인된 상태입니다.(Keystone authentication is currently logged in.)"  >> "$LOG_FILE" 2>&1
    echo "$tokenInfo"

    imagesDirectoryCheck
  fi
}

askForLoginKeystone() {
  echo "[$ACCESS_DATE] [INFO] Keystone 로그인이 필요합니다.(Keystone login is required.)"
  echo "[$ACCESS_DATE] [INFO] Keystone 로그인이 필요합니다.(Keystone login is required.)" >> "$LOG_FILE" 2>&1

  read -r -p "Keystone에 로그인 해볼까요? Should I log in to Keystone? (Y/n): " loginChoice
  loginChoice="${loginChoice,,}"  # 입력을 소문자로 변환

  if [[ "$loginChoice" == "y" || "$loginChoice" == "yes" ]];
  then
    # Keystone 로그인 명령어 실행

    read -r -p "Keystone URL 정보를 입력해 주세요. 예-http://keystone.example.com:5000/v3 (Please enter Keystone URL information. example-예-http://keystone.example.com:5000/v3)  : " keystoneAuthUrl
    read -r -p "Keystone 계정 ID를 입력해 주세요. (Please enter Keystone account ID.)  : " keystoneUserName
    read -r -p "Keystone 계정 비밀번호를 입력해 주세요. (Please enter the Keystone account password.)  : " keystoneUserPassword
    read -r -p "로그인할 오픈스택 도메인 이름을 입력해 주세요. (Please enter the Open Stack domain name to log in to.)  : " domainNameForKeystoneLogin
    read -r -p "로그인할 프로젝트 이름을 입력해 주세요. (Please enter the name of the project you want to log in to.)  : " projectNameForKeystoneLogin

    createBootStrap "$keystoneAuthUrl" "$keystoneUserName" "$keystoneUserPassword" "$domainNameForKeystoneLogin" "$projectNameForKeystoneLogin"
    createKeystoneRc "$keystoneAuthUrl" "$keystoneUserName" "$keystoneUserPassword" "$domainNameForKeystoneLogin" "$projectNameForKeystoneLogin"

    imagesDirectoryCheck
  else
    echo "[$ACCESS_DATE] [INFO] Keystone에 로그인 하지 않을 경우 Image를 만들 수 없어요. 🤔(Image cannot be created if you do not log in to Keystone. 🤔)"
    echo "[$ACCESS_DATE] [INFO] Keystone에 로그인 하지 않을 경우 Image를 만들 수 없어요. 🤔(Image cannot be created if you do not log in to Keystone. 🤔)" >> "$LOG_FILE" 2>&1

    checkKeystoneAuthorizedValidateToken
  fi
}

createBootStrap() {
  local keystoneAuthUrl=$0
  local keystoneUserName=$1
  local keystoneUserPassword=$2
  local domainNameForKeystoneLogin=$3
  local projectNameForKeystoneLogin=$4

cat <<EOF > /root/bootstrap-keystone1
--bootstrap-admin-url "$keystoneAuthUrl"
--bootstrap-internal-url "$keystoneAuthUrl"
--bootstrap-public-url "$keystoneAuthUrl"
--bootstrap-region-id RegionOne
EOF

  chmod +x /root/bootstrap-keystone
  source /root/bootstrap-keystone

  if [ $? -eq 0  ];
  then
  echo "[$ACCESS_DATE] [INFO] bootstrap-keystone 실행 성공(bootstrap-keystone execution successful)"
  echo "[$ACCESS_DATE] [INFO] bootstrap-keystone 실행 성공(bootstrap-keystone execution successful)" >> "$LOG_FILE" 2>&1
else
  echo "[$ACCESS_DATE] [ERROR] bootstrap-keystone 실행 실패(bootstrap-keystone execution failed)"
  echo "[$ACCESS_DATE] [ERROR] bootstrap-keystone 실행 실패(bootstrap-keystone execution failed)" >> "$LOG_FILE" 2>&1

  exit 1
  fi
}

createKeystoneRc() {
  local keystoneAuthUrl=$0
  local keystoneUserName=$1
  local keystoneUserPassword=$2
  local domainNameForKeystoneLogin=$3
  local projectNameForKeystoneLogin=$4

cat <<EOF > /root/keystonerc
export OS_PROJECT_DOMAIN_NAME="$domainNameForKeystoneLogin"
export OS_USER_DOMAIN_NAME="$domainNameForKeystoneLogin"
export OS_PROJECT_NAME="$projectNameForKeystoneLogin"
export OS_USERNAME="$keystoneUserName"
export OS_PASSWORD="$keystoneUserName"
export OS_AUTH_URL="$keystoneAuthUrl"
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export PS1='\u@\h \W(keystone)\$ '
export OS_VOLUME_API_VERSION=3
export OS_VOLUME_API_VERSION=3
EOF

  chmod +x /root/keystonerc
  source /root/keystonerc

  if [ $? -eq 0  ];
  then
  echo "[$ACCESS_DATE] [INFO] keystonerc 실행 성공(keystonerc execution successful)"
  echo "[$ACCESS_DATE] [INFO] keystonerc 실행 성공(keystonerc execution successful)" >> "$LOG_FILE" 2>&1
else
  echo "[$ACCESS_DATE] [ERROR] keystonerc 실행 실패(bootstrap-keystone execution failed)"
  echo "[$ACCESS_DATE] [ERROR] keystonerc 실행 실패(keystonerc execution failed)" >> "$LOG_FILE" 2>&1

  exit 1
  fi
}

imagesDirectoryCheck() {
  echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재하는지 확인할게요.(Verify that there is a Directory where the Cloud Virtual Machine Image is stored.)"
  echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재하는지 확인할게요.(Verify that there is a Directory where the Cloud Virtual Machine Image is stored.)"  >> "$LOG_FILE" 2>&1

  if [ -d "$IMAGES_DIR" ];
  then
    echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재 합니다.(Directory exists where the Cloud Virtual Machine Image is stored.)"
    echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재 합니다.(Directory exists where the Cloud Virtual Machine Image is stored.)" >> "$LOG_FILE" 2>&1
  else
    echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재하지 않아 Directory를 생성할게요.(There is no Directory where the Cloud Virtual Machine Image will be stored, so we will create a Directory.)"
    echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image가 저장될 Directory가 존재하지 않아 Directory를 생성할게요.(There is no Directory where the Cloud Virtual Machine Image will be stored, so we will create a Directory.)" >> "$LOG_FILE" 2>&1
    mkdir -p $IMAGES_DIR

    if [ $? != 0 ];
    then
      echo "[$ACCESS_DATE] [ERROR] Cloud Virtual Machine Image 저장을 위한 Directory 만들기 실패 하였습니다.(Failed to create Directory for Cloud Virtual Machine Image Storage.)"
      echo "[$ACCESS_DATE] [ERROR] Cloud Virtual Machine Image 저장을 위한 Directory 만들기 실패 하였습니다.(Failed to create Directory for Cloud Virtual Machine Image Storage.)" >> "$LOG_FILE" 2>&1
      exit 1
     else
       echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Directory for Cloud Virtual Machine Image Storage does not exist and was created.)"
      echo "[$ACCESS_DATE] [INFO] Cloud Virtual Machine Image 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Directory for Cloud Virtual Machine Image Storage does not exist and was created.)" >> "$LOG_FILE" 2>&1
     fi
  fi

  choiceWork
}

choiceWork() {

  echo "[$ACCESS_DATE] [INFO] 어떤 작업을 진행해 볼까요? 숫자만 입력할 수 있어요.(What kind of work should we do? You can only enter numbers.)"
  echo "[$ACCESS_DATE] [INFO] 어떤 작업을 진행해 볼까요? 숫자만 입력할 수 있어요.(What kind of work should we do? You can only enter numbers.)" >> "$LOG_FILE" 2>&1

  select operationSystem in "이미지 저장소 정보 조회(Query image store information)" "이미지 내려 받기(Downloading an Image)" "종료(exit)";
    do
      case $REPLY in
      "1")
        chmod +x "$ROOT_PATH"/check/getDownloadSiteList.sh
        "$ROOT_PATH"/check/getDownloadSiteList.sh
        chmod +x "$ROOT_PATH"/check/getDownloadSiteList.sh;;
      "2")
        selectedByOptionOperationSystem;;
      "3")
        break;;
      *)
        echo "올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      esac
    done
}

selectedByOptionOperationSystem() {

  checkGlanceImageList

  echo "[$ACCESS_DATE] [INFO] 어떤 종류의 Image를 만들고 싶으세요? 숫자만 입력할 수 있어요.(What kind of image do you want to make? You can only enter numbers.)"
  echo "[$ACCESS_DATE] [INFO] 어떤 종류의 Image를 만들고 싶으세요? 숫자만 입력할 수 있어요.(What kind of image do you want to make? You can only enter numbers.)" >> "$LOG_FILE" 2>&1

  select operationSystem in "All Images" "CentOS" "CirrOS(test)" "Debian" "Fedora" "Microsoft Windows" "Ubuntu" "openSUSE and SUSE Linux Enterprise Server" "FreeBSD, OpenBSD, and NetBSD" "Arch Linux" "종료(exit)";
  do
    case $REPLY in
    "1")
      #./getAllImages.sh
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
     #break;;
    "2")
      selectedByCentOsVersion
      selectedByOptionOperationSystem;;
      #break
    "3")
      #selectedByCirrOsVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
    "4")
      #selectedByDebianVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
    "5")
      selectedByFedoraVersion
      selectedByOptionOperationSystem;;
      #break;;
    "6")
      #selectedByWindowsVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
    "7")
      selectedByUbuntuKind;;
      #break;;
    "8")
      #selectedBySUSEVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
    "9")
      #selectedByBSDVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
   "10")
      #selectedByArchLinuxVersion
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)"
      echo "[$ACCESS_DATE] [NOTICE] 현재 준비 중이에요. 빠르게 업데이트 해 드릴게요! 기대해 주세요. 😊(I'm preparing right now. I'll update you quickly! Please look forward to it. 😊)" >> "$LOG_FILE" 2>&1
      ;;
      #break;;
    "11")
      break;;
    *)
      echo "올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
    esac
  done
}

selectedByCentOsVersion() {
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs6/getCentOs6Images.sh
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs7/getCentOs7Images.sh
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8/getCentOs8Images.sh
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8Stream/getCentOs8StreamImages.sh
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs9Stream/getCentOs9StreamImages.sh

  echo "어떤 Version Image를 만들고 싶으세요? 번호를 입력해 주세요.(What version image do you want to make? Please enter your number.)"

  select version in "CentOS 6" "CentOS 7" "CentOS 8" "CentOS 8 Stream" "CentOS 9 Stream" "뒤로 가기 (Back)" "종료(exit)";
  do
    case $REPLY in
    "1")
      "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs6/getCentOs6Images.sh
      break;;
    "2")
      "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs7/getCentOs7Images.sh
      break;;
    "3")
      "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8/getCentOs8Images.sh
      break;;
    "4")
      "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8Stream/getCentOs8StreamImages.sh
      break;;
    "5")
      "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs9Stream/getCentOs9StreamImages.sh
      break;;
    "6")
      break;;
    "7")
      exit 0;;
    *)
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)" >> "$LOG_FILE" 2>&1
    esac
  done

  chmod -x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs6/getCentOs6Images.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs7/getCentOs7Images.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8/getCentOs8Images.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs8Stream/getCentOs8StreamImages.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/centOs/centOs9Stream/getCentOs9StreamImages.sh
}

selectedByFedoraVersion() {
  read -r -p "현재 내려 받을 수 있는 버전은 38 버전이에요. 계속 진행하실래요? (There are 38 versions that can be downloaded again. Would you like to continue?) (n(N) 혹은 no(NO)는 취소, y(Y), yes(YES)는 진행 - Cancel n(N) or no(NO), continue y(Y) and yes(YES)?: " choiceContinueOption

  if [[ "$choiceContinueOption" == "n" || "$choiceContinueOption" == "no" ]];
  then
    return
  elif [[ "$choiceContinueOption" == "y" || "$choiceContinueOption" == "yes" ]]
  then
    chmod +x "$ROOT_PATH"/createVirtualMachineImage/fedora/38/getFedora38Image.sh
    "$ROOT_PATH"/createVirtualMachineImage/fedora/38/getFedora38Image.sh
    chmod -x "$ROOT_PATH"/createVirtualMachineImage/fedora/38/getFedora38Image.sh
  else
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex"
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex" >> "$LOG_FILE" 2>&1

    selectedByFedoraVersion
  fi
}

selectedByWindowsVersion() {
  read -r -p "현재 내려 받을 수 있는 종류는 2012 R2이에요. 계속 진행하실래요? (Currently, you can download the 2012 R2. Would you like to continue?) (n(N) 혹은 no(NO)는 취소, y(Y), yes(YES)는 진행 - Cancel n(N) or no(NO), continue y(Y) and yes(YES)?: " choiceContinueOption

  echo "[$ACCESS_DATE] [INFO] 다른 Windows가 필요하다면 여기를 참고해 주세요. https://github.com/cloudbase/windows-imaging-tools (If you need another Windows, please refer to it here. https://github.com/cloudbase/windows-imaging-tools)"
  echo "[$ACCESS_DATE] [INFO] 다른 Windows가 필요하다면 여기를 참고해 주세요. https://github.com/cloudbase/windows-imaging-tools (If you need another Windows, please refer to it here. https://github.com/cloudbase/windows-imaging-tools)" >> "$LOG_FILE" 2>&1

  if [[ "$choiceContinueOption" == "n" || "$choiceContinueOption" == "no" ]];
  then
    return
  elif [[ "$choiceContinueOption" == "y" || "$choiceContinueOption" == "yes" ]]
  then
    chmod +x "$ROOT_PATH"/createVirtualMachineImage/windows/2012_r2/getWindows2012R2Image.sh
    "$ROOT_PATH"/createVirtualMachineImage/windows/2012_r2/getWindows2012R2Image.sh
    chmod -x "$ROOT_PATH"/createVirtualMachineImage/windows/2012_r2/getWindows2012R2Image.sh
  else
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex"
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex" >> "$LOG_FILE" 2>&1

    selectedByWindowsVersion
  fi
}

selectedByUbuntuKind() {
  echo "어떤 종류의 Image를 만들고 싶으세요? 번호를 입력해 주세요.(What version image do you want to make? Please enter your number.)"

  select kind in "All Images" "unMinimal" "minimal" "뒤로 가기 (Back)" "종료(exit)"; do
    case $REPLY in
    "1")
    getAllUbuntuUnMinimal
    getAllUbuntuMinimal;;
    "2")
    selectedByUnMinimalVersion;;
    "3")
    selectedByMinimalVersion;;
    "4")
    break;;
    "5")
    exit 0;;
    *)
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)" >> "$LOG_FILE" 2>&1
    esac
  done
}

selectedByUnMinimalVersion() {
  echo "어떤 Version Image를 만들고 싶으세요? 번호를 입력해 주세요.(What version image do you want to make? Please enter your number.)"

  select version in "All Images" "ubuntu18.04LTS" "ubuntu20.04LTS" "ubuntu22.04LTS" "ubuntu23.04" "ubuntu23.10" "뒤로 가기 (Back)" "종료(exit)"; do
    case $REPLY in
    "1")
      getAllUbuntuUnMinimal;;
    "2")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh;;
    "3")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh;;
    "4")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh;;
    "5")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh;;
    "6")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh;;
    "7")
      break;;
    "8")
      exit 0;;
    *)
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)" >> "$LOG_FILE" 2>&1
    esac
  done
}

getAllUbuntuUnMinimal() {
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu18.04LTS.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu20.04LTS.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu22.04LTS.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.04.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/getUbuntu23.10.sh
}

selectedByMinimalVersion() {
  echo "어떤 Minimal Version Image를 만들고 싶으세요? 번호를 입력해 주세요.(What Minimal version image do you want to make? Please enter your number.)"

  select version in "All Images" "ubuntuMinimal18.04LTS" "ubuntuMinimal18.10" "ubuntuMinimal19.04" "ubuntuMinimal19.10" "ubuntuMinimal20.04" "ubuntuMinimal20.10" "ubuntuMinimal21.04" "ubuntuMinimal21.10" "ubuntuMinimal22.04LTS" "ubuntuMinimal22.10" "ubuntuMinimal23.04" "ubuntuMinimal23.10" "뒤로 가기 (Back)" "종료(exit)"; do
    case $REPLY in
    "1")
      getAllUbuntuMinimal;;
    "2")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh;;
    "3")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh;;
    "4")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh;;
    "5")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh;;
    "6")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh;;
    "7")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh;;
    "8")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh;;
    "9")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh;;
    "10")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh;;
    "11")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh;;
    "12")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh;;
    "13")
      chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh
      "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh
      chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh;;
    "14")
      break;;
    "15")
      exit 0;;
    *)
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)"
      echo "[$ACCESS_DATE] [WARNING] 올바른 선택이 아닙니다. 다시 선택해주세요.(This is not the correct choice. Please select again by entering only numbers.)" >> "$LOG_FILE" 2>&1
    esac
  done
}

getAllUbuntuMinimal() {
  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.04LTS.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal18.10.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.04.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal19.10.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.04.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal20.10.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.04.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal21.10.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.04LTS.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal22.10.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.04.sh

  chmod +x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh
  "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh
  chmod -x "$ROOT_PATH"/createVirtualMachineImage/ubuntu/minimal/getUbuntuMinimal23.10.sh
}

checkGlanceImageList() {
  openstack image list
  openStackImageListCount=$(openstack image list | grep -v '+' | grep -v 'ID' | grep -v 'Name' | grep -v 'Status' | wc -l)

  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageListCount"
  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageListCount" >> "$LOG_FILE" 2>&1
}

echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 동작(Open Stack Image Download Script Behavior) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"

licenseNotice

echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"
echo "==== [$ACCESS_DATE] 오픈스택 이미지 내려받기 스크립트 작업 끝(Open Stack Image Download Script Operation Finished) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1
echo "==== [$ACCESS_DATE] 오픈스택 이미지 내려받기 스크립트 작업 끝(Open Stack Image Download Script Operation Finished) ===="  >> "$LOG_FILE" 2>&1
