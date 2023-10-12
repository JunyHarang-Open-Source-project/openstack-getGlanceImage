#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")
ROOT_PATH=$(pwd)
LOG_DIR="/var/log/openstack/glance/image/Ubuntu/${TODAY}"
LOG_FILE="${LOG_DIR}/createOpenStackImages.log"
IMAGES_DIR="/root/download/openstack/images"
DOWNLOAD_OS_NAME="ubuntu18.04LTS"
DOWNLOAD_OS_SITE_LIST_INI_FILE="$ROOT_PATH/check/downloadSiteList.ini"
DOWNLOAD_SITE_URL=""

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

  getOsList
}

getImageStorageInfo() {
  echo "[$ACCESS_DATE] [DEBUG] 등록된 이미지 저장소 정보를 가져올게요. (I'll get the registered image store information.)"
  echo "[$ACCESS_DATE] [DEBUG] 등록된 이미지 저장소 정보를 가져올게요. (I'll get the registered image store information.)" >> "$LOG_FILE" 2>&1

  # downloadSiteList.ini 파일을 읽고 구문 분석
  while IFS='=' read -r key value; do
    # Remove leading/trailing whitespace
    key=${key%%*( )}  # Remove leading whitespace
    key=${key##*( )}  # Remove trailing whitespace
    value=${value%%*( )}
    value=${value##*( )}

    if [[ $key == "$DOWNLOAD_OS_NAME" ]]; then
      ubuntuSites["$key"]="$value"
    else
      continue
    fi

  done < "$DOWNLOAD_OS_SITE_LIST_INI_FILE"
}

getOsList() {
  resultArray=()

  for imageDownloadTargetName in "${!ubuntuSites[@]}"; do

    echo "[$ACCESS_DATE] [DEBUG] imageDownloadSiteName 변수값: $imageDownloadTargetName"

    if [[ "$imageDownloadTargetName" == "$DOWNLOAD_OS_NAME" ]]; then
      echo "[$ACCESS_DATE] [INFO] $DOWNLOAD_OS_NAME 이미지를 내려 받을게요.(download the image for $DOWNLOAD_OS_NAME.) 내려 받는 곳(From): ${ubuntuSites[$imageDownloadTargetName]}"
      echo "[$ACCESS_DATE] [INFO] $DOWNLOAD_OS_NAME 이미지를 내려 받을게요.(download the image for $DOWNLOAD_OS_NAME.) 내려 받는 곳(From): ${ubuntuSites[$imageDownloadTargetName]}" >> "$LOG_FILE" 2>&1
      getPageContent=$(wget -q -O - "${ubuntuSites[$imageDownloadTargetName]}")

      if [ "$getPageContent" -ne 0 ]; then
        echo "[$ACCESS_DATE] [DEBUG] WGET 명령 결과 확인: $getPageContent"
        echo "[$ACCESS_DATE] [DEBUG] WGET 명령 결과 확인: $getPageContent" >> "$LOG_FILE" 2>&1
      fi

      getCentosImageList=$(echo "$getPageContent" | grep -oE 'href=".*-server-cloudimg-amd64.img"' | sed 's/href="//' | sed 's/"//')
    fi
  done

  while IFS= read -r line;
  do
    resultArray+=("$line")
  done <<< "$getCentosImageList"

  imageListLength=${#resultArray[@]}

  echo "[$ACCESS_DATE] [DEBUG] imageListLength 변수값: $imageListLength"

  if [ "$imageListLength" -gt 1 ] && [ "${#ubuntuSites[@]}" -ge 1 ]; then
    numberImages "${resultArray[@]}"
  else
    DOWNLOAD_SITE_URL="${ubuntuSites[$imageDownloadTargetName]}"
    downloadImage "${resultArray[0]}"
    deleteEnvironmentSetting "${resultArray[0]}"
  fi
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

  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 내려 받을 Image 개수(Number of download images selected by the user): $choiceImagesNumber"
  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 내려 받을 Image 개수(Number of download images selected by the user): $choiceImagesNumber" >> "$LOG_FILE" 2>&1

  read -r -p "내려 받을 이미지 순서 번호를 선택 해주세요. (여러 개 선택 가능, 스페이스로 구분) Please select the image order number to download. (Multiple choices available, separated by space): " selectedNumbers

  IFS=' ' read -ra selectedArray <<< "$selectedNumbers"
  selectedUserImageCount="${#selectedArray[@]}"

  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수(Number of Image Order Numbers Selected by the User): $selectedUserImageCount"
  echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수(Number of Image Order Numbers Selected by the User): $selectedUserImageCount" >> "$LOG_FILE" 2>&1

  for downloadTagerImageIndex in "${selectedArray[@]}";
  do
    if [[ -n "$downloadTagerImageIndex" && "$selectedUserImageCount" == "$choiceImagesNumber" ]];
    then
      selectedImages+=("${imageList[$downloadTagerImageIndex]}")  # 선택한 이미지를 배열에 추가
    else
      echo "[$ACCESS_DATE] [WARNING] 잘못된 이미지 순서 번호를 입력했어요.(You entered the wrong image order number.) - $selectedNumbers"
      echo "[$ACCESS_DATE] [WARNING] 잘못된 이미지 순서 번호를 입력했어요.(You entered the wrong image order number.) - $selectedNumbers" >> "$LOG_FILE" 2>&1

      choiceImages
    fi
  done

  for image in "${selectedImages[@]}"; do
    DOWNLOAD_SITE_URL="${ubuntuSites[$image]}"
    (
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)"
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)" >> "$LOG_FILE" 2>&1
    downloadImage "$image"
    )&
  done
  wait

  deleteEnvironmentSetting "${selectedImages[@]}"
}

choiceAllImages() {
  local imageList=("$@")

  for image in "${imageList[@]}"; do
    DOWNLOAD_SITE_URL="${ubuntuSites[$image]}"
    (
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)"
    echo "[$ACCESS_DATE] [INFO] 내려 받을 Image 이름: $image(Image name to download: $image)" >> "$LOG_FILE" 2>&1
    downloadImage "$image"
    )&
  done
  wait

  deleteEnvironmentSetting "${imageList[@]}"
}

downloadImage() {
  local targetDownloadImage="$1"
  local targetDownloadImageUrl="$DOWNLOAD_SITE_URL$targetDownloadImage"

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
  imageName="${imageExtensionName%.img}"

  echo "[$ACCESS_DATE] [INFO] 내려 받은 이미지 $imageName 에 대해 OpenStack Image를 만들게요. (create an OpenStack image for the downloaded $imageName.)"
  echo "[$ACCESS_DATE] [INFO] 내려 받은 이미지 $imageName 에 대해 OpenStack Image를 만들게요. (create an OpenStack image for the downloaded $imageName.)" >> "$LOG_FILE" 2>&1

  openstack image create "$DOWNLOAD_OS_NAME-$imageName" --disk-format qcow2 --file "$IMAGES_DIR/$imageExtensionName" --container-format bare --public

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
  fi
}

deleteEnvironmentSetting() {
  local deleteTargetImageList=("$@")
  local deleteTargetImage=$1
  imageDirectorySize=$(du -sh "$IMAGES_DIR")
  downloadImageList=$(ls -al "$IMAGES_DIR")
  deleteTargetImageListLength=${#deleteTargetImageList[@]}
  selectedImages=()

  if [ "$deleteTargetImageListLength" -gt 1 ] && [ -z $deleteTargetImage ]; then
    choiceDeleteImageList "${deleteTargetImageList[@]}"
  else
    choiceDeleteImage "$deleteTargetImage"

    imageDirectorySize=$(du -sh "$IMAGES_DIR")
    downloadImageList=$(ls -al "$IMAGES_DIR")

    echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize"
    echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize" >> "$LOG_FILE" 2>&1
    echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList"
    echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList" >> "$LOG_FILE" 2>&1
    checkGlanceImageList
  fi
}

choiceDeleteImageList() {
  local deleteTargetImageList=("$@")
  deleteTargetImageListLength=${#deleteTargetImageList[@]}

  for ((index=0; index < deleteTargetImageListLength; index++));
  do
    echo "내려 받은 $index 번째 Image 이름(Downloaded $index Image Name) : ${deleteTargetImageList[$index]}"
  done

  echo "[$ACCESS_DATE] [INFO] Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information) (GB) : $imageDirectorySize"
  echo "[$ACCESS_DATE] [INFO] Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information) (GB) : $imageDirectorySize" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [INFO] 내려 받은 Image Directory 목록(Downloaded Image Directory List) : $downloadImageList"
  echo "[$ACCESS_DATE] [INFO] 내려 받은 Image Directory 목록(Downloaded Image Directory List) : $downloadImageList" >> "$LOG_FILE" 2>&1

  read -r -p "Glance Image를 만들기 위해 내려 받은 Image를 삭제하실래요? (Would you like to delete the downloaded image to create the Glance Image?) (n(N) 혹은 no(NO)는 취소, y(Y), yes(YES)는 삭제 - Cancel n(N) or no(NO), delete y(Y) and yes(YES)?: " choiceDeleteOption

  if [[ "$choiceDeleteOption" == "n" || "$choiceDeleteOption" == "no" ]]; then
    return
  elif [[ "$choiceDeleteOption" == "y" || "$choiceDeleteOption" == "yes" ]]; then
      read -r -p "Image를 어떻게 삭제 할까요? 전체 삭제 0, 선택 삭제 1 (How do I delete the Image? Delete All 0, Delete Selections 1)" choiceDeleteDetailOption

      if [ "$choiceDeleteDetailOption" -eq 0 ];
      then
        deleteImages "${deleteTargetImageList[@]}"
      elif [ "$choiceDeleteDetailOption" -eq 1 ]
      then
        read -r -p "삭제할 이미지 순서 번호를 선택 해주세요. (여러 개 선택 가능, 스페이스로 구분) Please select the image order number to download. (Multiple choices available, separated by space): " selectedDeletedImageNumbers

        IFS=' ' read -ra selectedArray <<< "$selectedDeletedImageNumbers"
        selectedUserImageCount="${#selectedArray[@]}"

        echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수(Number of Image Order Numbers Selected by the User): $selectedUserImageCount"
        echo "[$ACCESS_DATE] [DEBUG] 사용자가 선택한 Image 순서 번호 개수(Number of Image Order Numbers Selected by the User): $selectedUserImageCount" >> "$LOG_FILE" 2>&1

        for ((index=0; index < selectedUserImageCount; index++));
        do
          if [[ "$selectedUserImageCount" -gt 0 ]];
          then
            targetImageNum="${selectedArray[$index]}"

            echo "[$ACCESS_DATE] [DEBUG] 삭제를 위한 반복 회수 총 $selectedUserImageCount 중 $index 번째 삭제 대상 이미지 이름(Repeated count for deletion Total $selectedUserImageCount $index Destination Image Name): ${deleteTargetImageList[$targetImageNum]}"
            echo "[$ACCESS_DATE] [DEBUG] 삭제를 위한 반복 회수 총 $selectedUserImageCount 중 $index 번째 삭제 대상 이미지 이름(Repeated count for deletion Total $selectedUserImageCount $index Destination Image Name): ${deleteTargetImageList[$targetImageNum]}" >> "$LOG_FILE" 2>&1

            selectedImages+=("${deleteTargetImageList[$targetImageNum]}")  # 선택한 이미지를 배열에 추가

            echo "[$ACCESS_DATE] [DEBUG] 삭제를 위해 담은 대상 배열 값(Target array values contained for deletion): ${selectedImages[$index]}"
            echo "[$ACCESS_DATE] [DEBUG] 삭제를 위해 담은 대상 배열 값(Target array values contained for deletion): ${selectedImages[$index]}" >> "$LOG_FILE" 2>&1
          else
            echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $selectedDeletedImageNumbers"
            echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $selectedDeletedImageNumbers" >> "$LOG_FILE" 2>&1

            deleteEnvironmentSetting
          fi
        done

        deleteImages "${selectedImages[@]}"
      else
        echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $choiceDeleteDetailOption"
        echo "[$ACCESS_DATE] [WARNING] 잘못된 문자를 입력했어요.(You entered the wrong character) - $choiceDeleteDetailOption" >> "$LOG_FILE" 2>&1

        deleteEnvironmentSetting
        fi
      fi

  imageDirectorySize=$(du -sh "$IMAGES_DIR")
  downloadImageList=$(ls -al "$IMAGES_DIR")

  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize"
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 Image 저장 디렉터리 용량 정보(Image Storage Directory Capacity Information After Delete) (GB) : $imageDirectorySize" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList"
  echo "[$ACCESS_DATE] [INFO] 삭제 뒤 내려 받은 Image 목록(List of images downloaded after deletion) : $downloadImageList" >> "$LOG_FILE" 2>&1
  checkGlanceImageList
}

choiceDeleteImage() {
  read -r -p "Glance Image를 만들기 위해 내려 받은 Image를 삭제하실래요? (Would you like to delete the downloaded image to create the Glance Image?) (n(N) 혹은 no(NO)는 취소, y(Y), yes(YES)는 삭제 - Cancel n(N) or no(NO), delete y(Y) and yes(YES)?: " choiceDeleteOption

    if [[ "$choiceDeleteOption" == "n" || "$choiceDeleteOption" == "no" ]]; then
      return
    elif [[ "$choiceDeleteOption" == "y" || "$choiceDeleteOption" == "yes" ]]; then
      deleteImages "$deleteTargetImage"
    fi
}

deleteImages() {
  local deleteTargetImageList=("$@")
  local deleteTarget=$1

  if [ "${#deleteTargetImageList}" -ge 1 ] && [ -z "$deleteTarget" ]; then
    for deleteTargetImage in "${deleteTargetImageList[@]}"; do
      (
      echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $deleteTargetImage"
      echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $deleteTargetImage" >> "$LOG_FILE" 2>&1

      rm -rf "$IMAGES_DIR/$deleteTargetImage"
      deleteCommandResponse=$?

      if [ $deleteCommandResponse -eq 0 ]; then
        echo "[$ACCESS_DATE] [INFO] $deleteTargetImage 삭제 성공 (Successfully deleted $deleteTargetImage): $deleteCommandResponse"
        echo "[$ACCESS_DATE] [INFO] $deleteTargetImage 삭제 성공 (Successfully deleted $deleteTargetImage): $deleteCommandResponse" >> "$LOG_FILE" 2>&1
      else
        echo "[$ACCESS_DATE] [INFO] $deleteTargetImage 삭제 실패 (Failed to delete $deleteTargetImage): $deleteCommandResponse"
        echo "[$ACCESS_DATE] [INFO] $deleteTargetImage 삭제 실패 (Failed to delete $deleteTargetImage): $deleteCommandResponse" >> "$LOG_FILE" 2>&1
      fi
      )&
    done
    wait

  else
    echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $deleteTarget"
    echo "[$ACCESS_DATE] [DEBUG] 삭제 대상 이미지 이름(Delete target image name): $deleteTarget" >> "$LOG_FILE" 2>&1

    rm -rf "$IMAGES_DIR/$deleteTarget"
    deleteCommandResponse=$?

    if [ $deleteCommandResponse -eq 0 ]; then
      echo "[$ACCESS_DATE] [INFO] $deleteTarget 삭제 성공 (Successfully deleted $deleteTarget): $deleteCommandResponse"
      echo "[$ACCESS_DATE] [INFO] $deleteTarget 삭제 성공 (Successfully deleted $deleteTarget): $deleteCommandResponse" >> "$LOG_FILE" 2>&1
    else
      echo "[$ACCESS_DATE] [INFO] $deleteTarget 삭제 실패 (Failed to delete $deleteTarget): $deleteCommandResponse"
      echo "[$ACCESS_DATE] [INFO] $deleteTarget 삭제 실패 (Failed to delete $deleteTarget): $deleteCommandResponse" >> "$LOG_FILE" 2>&1
    fi
  fi
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
  openStackImageListCount=$(openstack image list | grep -v '+' | grep -v 'ID' | grep -v 'Name' | grep -v 'Status' | wc -l)

  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageListCount"
  echo "[$ACCESS_DATE] [NOTICE] 현재 보유중인 이미지 목록(List of images currently in possession): $openStackImageListCount" >> "$LOG_FILE" 2>&1
}

echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 동작(Open Stack $DOWNLOAD_OS_NAME Image Download Script Behavior) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"

licenseNotice

echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"
echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 작업 끝(Open Stack $DOWNLOAD_OS_NAME Image Download Script Operation Finished) ===="
echo "@Author: Juny(junyharang8592@gmail.com) - Tech Blog: https://junyharang.tistory.com/"  >> "$LOG_FILE" 2>&1
echo "==== [$ACCESS_DATE] 오픈스택 $DOWNLOAD_OS_NAME 이미지 내려받기 스크립트 작업 끝(Open Stack $DOWNLOAD_OS_NAME Image Download Script Operation Finished) ===="  >> "$LOG_FILE" 2>&1