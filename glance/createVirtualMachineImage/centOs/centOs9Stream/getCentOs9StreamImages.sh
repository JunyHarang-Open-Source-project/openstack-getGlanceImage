#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
LOG_DIR="/var/log/openstack/glance/image/centOs9Stream/${TODAY}"
LOG_FILE="${LOG_DIR}/createOpenStackImages.log"
IMAGES_DIR="/root/download/openstack/images"

# -------------------------------------------------------
# SSH Access Web Hook Notification
# Written by: Juny(junyharang8592@gmail.com)
# Last updated on: 2023/10/08
# -------------------------------------------------------

GET_CENT_OS_URL="https://cloud.centos.org/centos/9-stream/x86_64/images/"

licenseNotice() {

  echo "[$ACCESS_DATE] [NOTICE] 해당 Shell Script License에 대한 내용 고지합니다. 숙지하시고, 사용 부탁드립니다."

  echo "[$ACCESS_DATE] [NOTICE] http://opensource.org/licenses/MIT"
  echo "[$ACCESS_DATE] [NOTICE] Copyright (c) 2023 juny(juny8592@gmail.com)"
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
    echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 동작(Open Stack CentOS 7 Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
    echo "@Author: Juny(junyharang8592@gmail.com)"  >> "$LOG_FILE" 2>&1

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
       echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 동작(Open Stack CentOS 7 Image Download Script Behavior) ===="  >> "$LOG_FILE" 2>&1
       echo "@Author: Juny(junyharang8592@gmail.com)"  >> "$LOG_FILE" 2>&1

       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)"
       echo "[$ACCESS_DATE] [INFO] Log 저장을 위한 Directory가 존재 하지 않아 생성 하였습니다.(Created because Directory for Log Storage does not exist.)" >> "$LOG_FILE" 2>&1
     fi
  fi

  getCentOSList
}

getCentOSList() {
  resultArray=()
  echo "[$ACCESS_DATE] [INFO] CentOS에 대한 이미지를 내려 받을게요. 내려 받는 곳: $GET_CENT_OS_URL (download the image for CentOS. From: $GET_CENT_OS_URL)"
  echo "[$ACCESS_DATE] [INFO] CentOS에 대한 이미지를 내려 받을게요. 내려 받는 곳: $GET_CENT_OS_URL (download the image for CentOS. From: $GET_CENT_OS_URL)" >> "$LOG_FILE" 2>&1

  # 페이지 내용을 wget을 사용하여 가져옵니다.(Import page contents using wget.)
  getPageContent=$(wget -q -O - "$GET_CENT_OS_URL")

  getCentosImageList=$(echo "$getPageContent" | grep -oE 'href=".*GenericCloud.*\.qcow2"' | sed 's/href="//' | sed 's/"//')

  while IFS= read -r line;
  do
    resultArray+=("$line")
  done <<< "$getCentosImageList"

  numberImages "${resultArray[@]}"
}

numberImages() {
  local imageList=("$@")
  echo "${imageList[@]}"
  imageListLength=${#imageList[@]}

  for ((index=0; index < imageListLength; index++));
  do
    echo "$index 번째 Image 이름($index . Image Name) : ${imageList[$index]}"
  done

  while true;
  do
    read -r -p "어떻게 Image를 내려 받을까요? (0은 전체 선택, 1은 선택적으로 내려 받기) How do I download the image? (0 is overall selection, 1 is selectively downloaded): " choiceImagesNumber

    if [ "$choiceImagesNumber" -eq 0 ];
      then
        choiceAllImages "${imageList[@]}"
        break
    elif [ "$choiceImagesNumber" -eq 1 ];
      then
        choiceImages "${imageList[@]}"
        break
    else
      echo "[$ACCESS_DATE] [WARNING] 잘못된 번호가 입력 되었어요. 0 아니면 1만 입력할 수 있어요. 입력된 번호(The wrong number has been entered. If it's not 0, you can only enter 1. Number entered): $choiceImagesNumber"
      echo "[$ACCESS_DATE] [WARNING] 잘못된 번호가 입력 되었어요. 0 아니면 1만 입력할 수 있어요. 입력된 번호(The wrong number has been entered. If it's not 0, you can only enter 1. Number entered): $choiceImagesNumber" >> "$LOG_FILE" 2>&1
    fi
  done
}

choiceImages() {
  local imageList=("$@")
  selectedImages=()  # 선택한 이미지를 저장할 배열 초기화
  imageListLength="${#imageList[@]}"

  read -r -p "몇 개의 Image가 필요해요? (선택 가능한 개수: $imageListLength) How many images do you need? (selectable number: $imageListLength): " choiceImagesNumber

  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 내려 받을 Image 개수: $choiceImagesNumber"
  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 내려 받을 Image 개수: $choiceImagesNumber" >> "$LOG_FILE" 2>&1

  read -p "내려 받을 이미지 순서 번호를 선택 해주세요. (여러 개 선택 가능, 스페이스로 구분) Please select the image order number to download. (Multiple choices available, separated by space): " selectedNumbers

  IFS=' ' read -ra selectedArray <<< "$selectedNumbers"
  selectedUserImageCount="${#selectedArray[@]}"

  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수: $selectedUserImageCount"
  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수: $selectedUserImageCount" >> "$LOG_FILE" 2>&1

  for imageListIndex in "${selectedArray[@]}";
  do
    if [[ "$imageListIndex" -ge 0 &&  "$selectedUserImageCount" == "$choiceImagesNumber" ]];
    then
      selectedImages+=("${imageList[$imageListIndex]}")  # 선택한 이미지를 배열에 추가
    else
      echo "[$ACCESS_DATE] [WARNING] 잘못된 이미지 순서 번호를 입력했어요.(You entered the wrong image order number.) - $imageListIndex"
      echo "[$ACCESS_DATE] [WARNING] 잘못된 이미지 순서 번호를 입력했어요.(You entered the wrong image order number.) - $imageListIndex" >> "$LOG_FILE" 2>&1

      choiceImages
    fi
  done

  for image in "${selectedImages[@]}";
  do
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)"
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)" >> "$LOG_FILE" 2>&1
    downloadImage "$image"
  done
}

choiceAllImages() {
  local imageList=("$@")

  for image in "${imageList[@]}";
  do
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)"
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)" >> "$LOG_FILE" 2>&1
    downloadImage "$image"
  done
}

downloadImage() {
  local targetDownloadImage="$1"
  local targetDownloadImageUrl="$GET_CENT_OS_URL$targetDownloadImage"

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
  imageName="${imageExtensionName%.qcow2}"

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

echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 동작(Open Stack CentOS Image Download Script Behavior) ===="
echo "@Author: Juny(junyharang8592@gmail.com)"

licenseNotice

echo "@Author: Juny(junyharang8592@gmail.com)"
echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 작업 끝(Open Stack CentOS Image Download Script Operation Finished) ===="
echo "@Author: Juny(junyharang8592@gmail.com)"  >> "$LOG_FILE" 2>&1
echo "==== [$ACCESS_DATE] 오픈스택 CentOS 이미지 내려받기 스크립트 작업 끝(Open Stack CentOS Image Download Script Operation Finished) ===="  >> "$LOG_FILE" 2>&1