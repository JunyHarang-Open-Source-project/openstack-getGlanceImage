[KOREAN](https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/blob/master/README.md) | [For English](https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/blob/master/README.en.md)

# OpenStack Glance Image Download Program

## 🚀 what's this for
* You can get virtual images to Glance more conveniently in the OpenStack Controller Node.

## 🚀 How to Use
### 🔽 Please download all shell scripts!
  ```bash
  git clone https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage.git
  ```
![img.png](readme/images/img.png)
<br><br>

### 🔽 Please grant permission to run OpenStack/glance/createOpenStackImages.sh
   ```bash
    chmod +x your/path/openstack-getGlanceImage/glance/createVirtualMachineImage/createOpenStackImages.sh
   ```

![img_1.png](readme/images/img_1.png)
<br><br>

### 🔽 Please run createOpenStackImages.sh .
  ```bash
    your/path/openstack-getGlanceImage/glance/createVirtualMachineImage/createOpenStackImages.sh
  ```
<br><br>
### 🔽 Please select the OS type you want to download.
#### 📦 Selective Download
![img_2.png](readme/images/img_2.png)<br><br>
![img_21.png](readme/images/img_21.png)<br><br>
![img_4.png](readme/images/img_4.png)<br><br>
![img_5.png](readme/images/img_5.png)
- If you select number 1, you can select the OS image you need and download it.<br><br>
  ![img_6.png](readme/images/img_6.png)
- Check the list that can be downloaded, and if you enter 0, you can download the entire image, and if you enter 1, you can select and download only the image you need.<br><br>
  ![img_7.png](readme/images/img_7.png)
- Please check the list to see the images you need and enter the number of downloads.<br><br>
  ![img_8.png](readme/images/img_8.png)
- Please enter the required number and check the list to enter a number based on the space of the required images.<br><br>
  ![img_22.png](readme/images/img_22.png)
- As above, downloading the image from list 0 to 2 in parallel will proceed at the same time.<br><br>
  ![img_23.png](readme/images/img_23.png)
  ![img_24.png](readme/images/img_24.png)
- If the image download is successful, it automatically generates a Glance image in parallel.<br><br>
  ![img_25.png](readme/images/img_25.png)
- Please select whether you want to delete the downloaded image. If you enter n or N, no, NO, we will not delete it, and we will move on.
- Number 0 is deleted by selecting number 1 of the entire image received above.
- If you delete it, the Glance image remains the same, and only the downloaded image is deleted.<br><br>
  ![img_26.png](readme/images/img_26.png)
- As above, you can selectively delete only the images you want to delete.<br><br>
  ![img_27.png](readme/images/img_27.png)
- You can see that the image is successfully registered in OpenStack.<br><br><br><br>

#### 📦 Download a full specific OS image
![img_28.png](readme/images/img_28.png)
- Let's proceed with the full download without CentOS 6 Image being registered.<br><br>
  ![img_29.png](readme/images/img_29.png)
  ![img_30.png](readme/images/img_30.png)
  ![img_31.png](readme/images/img_31.png)<br><br>
  ![img_32.png](readme/images/img_32.png)
  ![img_33.png](readme/images/img_33.png)
  ![img_34.png](readme/images/img_34.png)
- If you choose number 0, you can download the entire image of the OS in parallel and register it as Glance.<br><br>
  ![img.png](readme/images/img_35.png)
  ![img_1.png](readme/images/img_36.png)<br><br>
  ![img.png](readme/images/img_37.png)
  ![img_1.png](readme/images/img_38.png)
- You can download all the images of a specific OS and register them on Glance.<br><br>
  ![img.png](readme/images/img_39.png)
  ![img_1.png](readme/images/img_40.png)
  ![img_2.png](readme/images/img_41.png)
  ![img_3.png](readme/images/img_42.png)
- If you select Delete All, you can erase all images at once as above.<br><br>

#### 📦 Lastly
![img.png](readme/images/img_43.png)
![img_1.png](readme/images/img_44.png)
- When you're done, and you're back here, you can type 11 if you want to end it.
<br><br>

### 🔽 Realese Note
https://github.com/JunyHarang-Open-Source-project/openstack-getGlanceImage/releases

### 🔽 Where should I leave the inquiry while using it?
   - **Please email me to junyharang8592@gmail.com. 🤭**
   - **Juny Harang Tech Blog: https://junyharang.tistory.com/**