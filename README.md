[한국어](https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/blob/master/README.md) | [For English](https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/blob/master/README.en.md)

[![김태용의 리눅스 쉘 스크립트 프로그래밍 입문, 제이펍](https://shopping-phinf.pstatic.net/main_3243614/32436142895.20221230074729.jpg?type=w300)](https://link.coupang.com/a/bb3Kah)<br>
"이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다."

# OpenStack Glance Image Download Program

## 🚀 무엇을 할 수 있나요?
* OpenStack Controller Node에서 Glance에 가상 이미지를 보다 편리하게 받을 수 있어요.

## 🚀 Release 1.2.1 버전 내려 받기 가능 목록
* CentOS 6, 7, 8, 8Steam, 9Stream
* Fedora37
* Ubuntu Unminimal, minimal

## 🚀 어떻게 사용할 수 있나요?
 ### 🔽 쉘 스크립트를 모두 내려 받아 주세요!
  ```bash
  git clone https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage.git
  ```
![img.png](readme/images/img.png)
<br><br>

 ### 🔽 OpenStack/glaance/managementOpenStackImages.sh에 실행 권한을 주세요.
   ```bash
    chmod +x your/path/openstack-getGlanceImage/glance/createVirtualMachineImage/managementOpenStackImages.sh
   ```

![img_1.png](readme/images/img_1.png)
<br><br>

 ### 🔽 managementOpenStackImages.sh를 실행 시켜 주세요.

  ```bash
    your/path/openstack-getGlanceImage/glance/createVirtualMachineImage/managementOpenStackImages.sh
  ```
<br><br>
### 🔽 내려 받기 원하는 OS 종류를 선택해 주세요.
#### 📦 선택적 내려받기
![img_2.png](readme/images/img_2.png)<br><br>
![img_21.png](readme/images/img_21.png)<br><br>
![img_4.png](readme/images/img_4.png)<br><br>
![img_5.png](readme/images/img_5.png)
- 1번을 선택하면 필요한 OS Image를 선택해서 내려 받을 수 있어요.<br><br>
![img_6.png](readme/images/img_6.png)
- 내려 받기 가능한 목록을 확인하고, 0번을 입력하면 전체 이미지 내려받기, 1번을 입력하면 필요한 이미지만 선택해서 내려 받을 수 있어요.<br><br>
![img_7.png](readme/images/img_7.png)
- 목록을 확인하여 필요한 Image들을 확인하고, 내려 받을 개수를 입력해 주세요.<br><br>
![img_8.png](readme/images/img_8.png)
- 필요 개수를 입력한 뒤 목록을 확인하여 필요한 Image 들을 공백을 기준으로 번호를 입력해 주세요.<br><br>
![img_22.png](readme/images/img_22.png)
- 위와 같이 목록 0번부터 2번까지 병렬로 동시에 Image 내려 받기가 진행될거에요.<br><br>
![img_23.png](readme/images/img_23.png)
![img_24.png](readme/images/img_24.png)
- 이미지 다운로드가 성공하면 병렬로 동시에 Glance 이미지를 자동으로 생성해요.<br><br>
![img_25.png](readme/images/img_25.png)
- 내려 받은 이미지를 삭제할 것인지 선택해 주세요. n 혹은 N, no, NO를 입력하면 삭제하지 않고, 다음으로 넘어갈거에요.
- 0번은 위에서 받은 이미지 전체 삭제 1번은 선택하여 삭제가 진행돼요.
- 삭제를 하게 되면 Glance 이미지는 그대로 있고, 내려 받은 이미지만 삭제돼요.<br><br>
![img_26.png](readme/images/img_26.png)
- 위와 같이 삭제를 원하는 이미지만 선택적으로 삭제할 수 있어요.<br><br>
![img_27.png](readme/images/img_27.png)
- OpenStack에 이미지가 정상적으로 등록된걸 확인할 수 있어요.<br><br><br><br>

#### 📦 특정 OS 이미지 전체 내려 받기
![img_28.png](readme/images/img_28.png)
- CentOS 6 Image가 등록되지 않은 상태에서 전체 내려 받기를 진행해 볼게요.<br><br>
 ![img_29.png](readme/images/img_29.png)
 ![img_30.png](readme/images/img_30.png)
 ![img_31.png](readme/images/img_31.png)<br><br>
 ![img_32.png](readme/images/img_32.png)
 ![img_33.png](readme/images/img_33.png)
 ![img_34.png](readme/images/img_34.png)
- 0번을 선택하게 되면 해당 OS의 전체 이미지를 병렬로 동시에 알아서 내려 받고, Glance로 등록할 수 있어요.<br><br>
![img.png](readme/images/img_35.png)
![img_1.png](readme/images/img_36.png)<br><br>
![img.png](readme/images/img_37.png)
![img_1.png](readme/images/img_38.png)
- 이렇게 편리하게 특정 OS의 이미지를 모두 내려 받고, Glance에 등록할 수 있어요.<br><br>
![img.png](readme/images/img_39.png)
![img_1.png](readme/images/img_40.png)
![img_2.png](readme/images/img_41.png)
![img_3.png](readme/images/img_42.png)
- 전체 삭제를 선택하면 위와 같이 모든 이미지를 한번에 지울 수 있어요.<br><br>

#### 📦 내려 받기 대상 사이트 확인
![img.png](readme/images/img_45.png)
![img_1.png](readme/images/img_46.png)
![img_2.png](readme/images/img_47.png)
- 위와 같이 1번을 누르고, 엔터를 누르면 내려 받을 OS 사이트의 정보를 확인할 수 있어요.<br><br>

![img_3.png](readme/images/img_48.png)
- 1번을 누르면 내려 받기 가능한 OS의 내려 받기 사이트의 정보를 모두 확인할 수 있어요.<br><br>

![img_4.png](readme/images/img_49.png)
![img_5.png](readme/images/img_50.png)
![img_6.png](readme/images/img_51.png)
- 이렇게 확인할 수 있어요.

### 🔽 Realese Note
https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/releases

### 🔽 사용 중 문의는 어디로 남기면 되나요?
  - **junyharang8592@gmail.com 으로 메일 부탁드릴게요. 🤭**
  - **주니하랑 기술 Blog: https://junyharang.tistory.com/**
<br><br>
[![Openstack Cloud Computing Cookbook - Third Edition Paperback](https://image.yes24.com/momo/TopCate2516/MidCate010/251596375.jpg)](https://link.coupang.com/a/bb3Kah)<br>
"이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다."