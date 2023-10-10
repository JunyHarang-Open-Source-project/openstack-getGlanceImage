#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
LOG_DIR="/var/log/openstack/glance/image/windows/${TODAY}"
LOG_FILE="${LOG_DIR}/createOpenStackImages.log"
IMAGES_DIR="/root/download/openstack/images"
DOWNLOAD_OS_NAME="Windows 2012 R2"

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

  downloadImage
}

downloadImage() {
  local targetDownloadImageUrl="https://cloudbase.it/euladownload.php?h=kvm"
  targetDownloadImage="euladownload.php\?h\=kvm"

  echo "[$ACCESS_DATE] [INFO] $targetDownloadImage Image 내려 받기를 진행할게요. 저장 디렉터리: $IMAGES_DIR (proceed with downloading the $targetDownloadImage image. Storage Directory: $IMAGES_DIR)"
  echo "[$ACCESS_DATE] [INFO] $targetDownloadImage Image 내려 받기를 진행할게요. 저장 디렉터리: $IMAGES_DIR (proceed with downloading the $targetDownloadImage image. Storage Directory: $IMAGES_DIR)" >> "$LOG_FILE" 2>&1

  wget "$targetDownloadImageUrl" -P "$IMAGES_DIR"

  wgetCommandStatus=$?

  if [ "$wgetCommandStatus" -eq 0 ];
  then
    echo "[$ACCESS_DATE] [INFO] 이미지 다운로드 성공(Successful downloading Image): $targetDownloadImage"
    echo "[$ACCESS_DATE] [INFO] 이미지 다운로드 성공(Successful downloading Image): $targetDownloadImage" >> "$LOG_FILE" 2>&1

    createdOpenStackImage "$targetDownloadImage"

  else
    echo "[$ACCESS_DATE] [ERROR] 이미지 다운로드 실패(Image download failed): $targetDownloadImage"
    echo "[$ACCESS_DATE] [ERROR] 이미지 다운로드 실패(Image download failed): $targetDownloadImage" >> "$LOG_FILE" 2>&1

    exit 1
  fi
}

createdOpenStackImage() {
  local imageExtensionName="$1"
  imageName="windows_server_2012_r_std_eval_20170321"

  echo "[$ACCESS_DATE] [INFO] 내려 받은 이미지 $imageName 에 대해 OpenStack Image를 만들게요. (create an OpenStack image for the downloaded $imageName.)"
  echo "[$ACCESS_DATE] [INFO] 내려 받은 이미지 $imageName 에 대해 OpenStack Image를 만들게요. (create an OpenStack image for the downloaded $imageName.)" >> "$LOG_FILE" 2>&1

  openstack image create "$imageName" --disk-format qcow2 --file "$IMAGES_DIR/$imageExtensionName" --container-format bare --public

  createdImageByOpenstackCommandStatus=$?

  if [ "$createdImageByOpenstackCommandStatus" -ne 0 ];
  then
    echo "[$ACCESS_DATE] [ERROR] 이미지 생성 실패(Image creation failed): $imageName"
    echo "[$ACCESS_DATE] [ERROR] 이미지 생성 실패(Image creation failed): $imageName" >> "$LOG_FILE" 2>&1
    echo "[$ACCESS_DATE] [ERROR] 실패 이유:(Reasons for failure): $createdImageByOpenstackCommandStatus"
    echo "[$ACCESS_DATE] [ERROR] 실패 이유:(Reasons for failure): $createdImageByOpenstackCommandStatus" >> "$LOG_FILE" 2>&1

    exit 1
  else
    echo "[$ACCESS_DATE] [INFO] 이미지 생성 완료(Image creation complete): $imageName"
    echo "[$ACCESS_DATE] [INFO] 이미지 생성 완료(Image creation complete): $imageName" >> "$LOG_FILE" 2>&1

    deleteImages "$imageExtensionName"
  fi
}

deleteImages() {
  targetDownloadImageName=$1
  imageDirectorySize=$(du -sh "$IMAGES_DIR")
  downloadImageList=$(ls -al "$IMAGES_DIR")

  echo "[$ACCESS_DATE] [INFO] Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information) (GB) : $imageDirectorySize"
  echo "[$ACCESS_DATE] [INFO] Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information) (GB) : $imageDirectorySize" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [INFO] 내려 받은 Image Directory 목록(Downloaded Image Directory List) : $downloadImageList"
  echo "[$ACCESS_DATE] [INFO] 내려 받은 Image Directory 목록(Downloaded Image Directory List) : $downloadImageList" >> "$LOG_FILE" 2>&1

  read -r -p "Glance Image를 만들기 위해 내려 받은 Image를 삭제하실래요? 삭제 대상 이미지 이름: $targetDownloadImageName (Would you like to delete the downloaded image to create the Glance Image? Delete target image name: $targetDownloadImageName) (n(N) 혹은 no(NO)는 취소, y(Y), yes(YES)는 삭제 - Cancel n(N) or no(NO), delete y(Y) and yes(YES)?: " choiceDeleteOption
  choiceDeleteOption="${choiceDeleteOption,,}"  # 입력을 소문자로 변환


  if [[ "$choiceDeleteOption" == "n" || "$choiceDeleteOption" == "no" ]];
  then
    return
  elif [[ "$choiceDeleteOption" == "y" || "$choiceDeleteOption" == "yes" ]]
  then

    if [ -n "$targetDownloadImageName" ];
    then
      echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $targetDownloadImageName"
      echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $targetDownloadImageName" >> "$LOG_FILE" 2>&1
      rm -rf "$IMAGES_DIR/$targetDownloadImageName"
    else
      echo "[$ACCESS_DATE] [WARNING] 삭제 대상 이미지가 존재하지 않아요. (Deleted target image does not exist.)"
      echo "[$ACCESS_DATE] [WARNING] 삭제 대상 이미지가 존재하지 않아요. (Deleted target image does not exist.)" >> "$LOG_FILE" 2>&1

      return
    fi
      deleteCommandResponse=$?
      checkDeleteCommandResponse $deleteCommandResponse "$targetDownloadImageName"
  else
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex"
    echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $imageListIndex" >> "$LOG_FILE" 2>&1

    deleteImages
  fi

  imageDirectorySize=$(du -sh "$IMAGES_DIR")
  downloadImageList=$(ls -al "$IMAGES_DIR")

  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize"
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList"
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList" >> "$LOG_FILE" 2>&1

  checkGlanceImageList
}

checkDeleteCommandResponse() {
  local commandResponseMessage=$1
  local deleteFileName=$2

  if [ "$commandResponseMessage" -eq 0 ]; then
    echo "[$ACCESS_DATE] [INFO] $deleteFileName 파일이 삭제되었습니다.(The $deleteFileName file has been deleted.)"
    echo "[$ACCESS_DATE] [INFO] $deleteFileName 파일이 삭제되었습니다.(The $deleteFileName file has been deleted.)" >> "$LOG_FILE" 2>&1
  else
    echo "[$ACCESS_DATE] [WARNING] $deleteFileName 파일이 삭제되지 못했습니다.(The $deleteFileName file could not be deleted.)"
    echo "[$ACCESS_DATE] [WARNING] $deleteFileName 파일이 삭제되지 못했습니다.(The $deleteFileName file could not be deleted.)" >> "$LOG_FILE" 2>&1
    echo "[$ACCESS_DATE] [WARNING] 문제 내용: $commandResponseMessage(Problematic: $commandResponseMessage)"
    echo "[$ACCESS_DATE] [WARNING] 문제 내용: $commandResponseMessage(Problematic: $commandResponseMessage)" >> "$LOG_FILE" 2>&1
  fi
}

checkGlanceImageList() {
  openstack image list
  openStackImageList=$?

  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageList"
  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageList" >> "$LOG_FILE" 2>&1
}

echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 동작(Open Stack $DOWNLOAD_OS_NAME Image Download Script Behavior) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"

licenseNotice

echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"
echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 작업 끝(Open Stack $DOWNLOAD_OS_NAME Image Download Script Operation Finished) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1
echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 작업 끝(Open Stack $DOWNLOAD_OS_NAME Image Download Script Operation Finished) ===="  >> "$LOG_FILE" 2>&1