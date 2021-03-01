# -kudos-bh_vision2
쿠도스 비전 2 설치 방법에 대해 정리한 페이지입니다.  
jetson 설치에 관한 내용과 노트북에 환경 설치에 대한 내용이 같이 있어서 혼란스러울수도 있습니다.  
jetson에서 rviz나 gazebu를 돌리기에는 너무 무겁습니다. 
반면 평범한 노트북에서는 rviz나 gazebu가 잘 돌아갑니다.  
따라서 jetson에는 ros-docker4 대신 ros-docker3을 가지고 설치를 진행해주시면 되겠습니다.  
또한 jetson에서는 nvidia-docker2설치과정은 넘어가시면 되겠습니다.  

---

# 환경
  - ubuntu18.04
  - jetson의 경우 jetpack 4.5
  
---

# 설정 순서
>설치하기 전에 한글설치정도는 하면 편하다  
>git을 설치해주고 다음 명령어를 입력해주자  
>git config --global credential.helper 'cache --timeout 720000'  
## 1. ros 이미지 파일 생성
  #### 1. 우분투에 docker를 설치한다.(host)  
  ```
  curl -fsSL https://get.docker.com/ | sudo sh
  
  sudo usermod -aG docker $USER
  
  #다음 명령어로 도커 설치를 확인한다.
  #docker version
  #또는 sudo docker version
  ```
  컴퓨터를 반드시 껐다 킨다
>원한다면 docker를 관리하기 쉽게 만들어준다.  
> sudo docker info | grep Root로 이미지 저장 경로를 확인 할 수 있다.
>```
>sudo docker info | grep Root
>```
>/lib/systemd/system/docker.service을 수정해준다. 
>```
>sudo gedit /lib/systemd/system/docker.service
>```
>파일 14라인에 --data-root 옵션으로 새로운 저장 경로를 설정한다.
>```
>ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/home/사용자 이름/docker/docker_build/
>```
>도커를 재부팅한다.
>```
>sudo service docker stop
>systemctl daemon-reload
>sudo service docker start
>mkdir ~/docker/
>cd ~/docker/
>mkdir docker_build
>```
>경로가 제대로 수정되었는지 확인한다.  
>도커 이미지를 지속적으로 생성하고 만들다보면 차지하는 용량이 너무 커질 수도 있는데 이때 이미지와 컨테이너를 정리하는 것이 필요하다.  
>sudo docker ps로 동작중인 컨테이너를 확인할 수 있다.  
>sudo docker ps -a로 정지한 컨테이너까지 확인할 수도 있다.  
>sudo docker rm [컨테이너id]로 컨테이너를 삭제할 수 있다.  
>sudo docker images로 이미지들을 확인할 수 있다.  
>sudo docker rmi [이미지id]로 이미지들을 삭제할 수 있다.  
>sudo docker rmi -f [이미지id]로 이미지를 삭제하면서 생성된 컨테이너도 같이 삭제할 수있다.  
>sudo docker commit 컨테이터이름 생성할이미지이름으로 생성된 컨테이너를 이미지화 할 수 있다.  

  #### 2. 가제부 ,rviz등의 사용을 위한 nvidia docker2 설치(host)  
  docker version 명령어로 도커 설치를 확인한다.    
  혹여 nvidia docker1이 설치되어 있을 수도 있으니 다음 명령어로 깔끔하게 삭제해준다.  
  ```
docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
sudo apt-get purge -y nvidia-docker
  ```
  apt키와 레포지스토리를 추가해준다.  
  ```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
  
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  
sudo apt-get update
  ```
  nvidia docker2 설치
  ```
  sudo apt-get install -y nvidia-docker2
  ```
  도커 데몬 리로드
  ```
  sudo pkill -SIGHUP dockerd
  ```
  도커 상에서 nvidia-smi 테스트
  ```
  docker run --runtime=nvidia --rm nvidia/cuda:10.2-devel nvidia-smi
  ```
  nvidia-container-toolkit 설치
  ```
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d   /nvidia-docker.list

  sudo apt update && sudo apt install -y nvidia-container-toolkit
  
  sudo systemctl restart docker
  ```
  
  #### 3. 원하는 경로에 ros-docker4폴더를 둔다.(host)  
  #### 4. 터미널에서 ros-docker4로 들어간뒤 build.sh파일을 실행시켜준다.(host)
  ```
  ./build.sh
  ```
  #### 5. 생성된 이미지를 확인한다. 아마 ros_kinect_full이라는 이미지가 생성되었을 것이다.(host)  
  #### 6. 같은 폴더에 docker_share 란 폴더가 있을 것이다.  
  #### 7. run-docker.sh파일을 실행시켜준다.(host)
  #### 8. 그러면 실행 터미널에서 이미지를 가지고 컨테이너를 만들어 접속한다.(host)
  #### 9. ls치면 docker_share이라는 폴더가 보일텐데 호스트 컴퓨터와 컨테이너 이미지가 공동으로 사용하는 폴더라 생각하면 된다. 이 폴더 아래에 catkin_ws를 설정해야함을 주의하자(docker)
  #### 10. 이제 본격적으로 ros를 설치한다.(docker)
  ```
  sudo apt-get install -y chrony ntpdate
  
  sudo ntpdate -q ntp.ubuntu.com
  
  sudo apt-get update && sudo apt-get install -y lsb-release && sudo apt-get clean all
  
  sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  
  sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
  
  sudo apt-get update && sudo apt-get upgrade -y
  
  sudo apt-get install ros-kinetic-desktop-full
  
  sudo apt-get install ros-kinetic-rqt*
  
  sudo rosdep init
  
  rosdep update
  
  sudo apt-get install python-rosinstall
  
  source /opt/ros/kinetic/setup.bash
  
  cd ~/docker_share/
  
  mkdir -p ~/docker_share/catkin_ws/src
  
  cd catkin_ws/src
  
  catkin_init_workspace
  
  cd ..
  
  catkin_make
  
  source ~/docker_share/catkin_ws/devel/setup.bash
  ```
  #### 11. roscore를 실행시켜보고 잘 되면 ctrl+C로 나간다.(docker)
  #### 12. gedit을 깐다.(docker)
  #### 13. 다음 명령을 입력한다.(docker)
  ```
  source /opt/ros/kinetic/setup.bash
  source ~/docker_share/catkin_ws/devel/setup.bash
  ```
  #### 14. gedit ~/.bashrc을 실행 시켜 다음의 내용을 삽입한다.(비슷해보이는 부분이 있을텐데 지우거나 수정하면 된다.)(docker)
  ```
  alias eb ='nano ~/.bashrc'
  alias sb ='source ~/.bashrc'
  alias cw ='cd ~/docker_share/catkin_ws'
  alias cs ='cd ~/docker_share/catkin_ws/src'
  alias cm ='cd ~/docker_share/catkin_ws && catkin_make'
  source /opt/ros/kinetic/setup.bash
  source ~/docker_share/catkin_ws/devel/setup.bash
  export ROS_MASTER_URI=http://localhost:11311
  export ROS_HOSTNAME=localhost
  ```
  
  #### 15.컨테이너는 휘발성이기 때문에 docker_share안의 내용물을 제외하고는 종료했다가 다시 실행하면 그 내역이 모두 날아가게된다. roscore 실행을 확인했다면 그 컨테이너를 이미지로 저장해준다.(위에 하는 방법 적혀있음<sudo docker commit 컨테이터이름 생성할이미지이름>), 나는 ros_kinect_full로 이미지 파일 이름을 통일할 것이기 때문에 이미지 파일 이름을 똑같이 해주면 편할 것이다. 이미지 파일로 만들어주면 ros설치는 종료다.(host)  
  #### 16. ros의 사용법은 큰 차이는 없다. 가장 큰 차이라면 호스트의 터미널을 실행시켰다면 ./run-docker.sh를 이용하여 컨테이너 터미널로 만들어주어야한다는 사실 정도이다. 터미널 4개를 틀고 각각 ./run-docker.sh을 실행시켜 준 후 각 터미널에 다음 명령을 입력하여 ros의 최종 설치를 확인한다.(host)
```
#각 터미널은 도커 환경을 활성화한 터미널
#터미널1
roscore

#터미널2
rosrun turtlesim turtlesim_node

#터미널3
rosrun turtlesim turtle_teleop_key

#터미널4
rqt_graph 
```

  #### 17. 마지막으로 rviz를 실행시켜 하드웨어 가속도 잘 되는지 확인한다.(nvidia 그래픽 카드에서만 확인함)
  ```
  #도커 터미널에서..
  rosrun rviz rviz
  ```
  
## 2. op3 설치(docker)  
도커에 op3설치를 시작한다.  
>참고 링크:https://emanual.robotis.com/docs/en/platform/op3/recovery/#recovery-of-robotis-op3  
>추가 로보티즈 ROS패키지를 설치한다.
```
sudo apt install libncurses5-dev v4l-utils

sudo apt install madplay mpg321

sudo apt install g++ git
```
>op3를 위한 ROS패키지를 설치한다.
```
cd ~/docker_share/catkin_ws/src

git clone https://github.com/ROBOTIS-GIT/face_detection.git

cd ~/docker_share/catkin_ws

catkin_make

sudo apt install ros-kinetic-robot-upstart

cd ~/docker_share/catkin_ws/src

git clone https://github.com/bosch-ros-pkg/usb_cam.git

cd ~/docker_share/catkin_ws

catkin_make

sudo apt install v4l-utils

sudo apt install ros-kinetic-qt-ros
```
>humanoid navigation을 설치한다.
```
sudo apt-get install ros-kinetic-map-server

sudo apt-get install ros-kinetic-humanoid-nav-msgs

sudo apt-get install ros-kinetic-nav-msgs

sudo apt-get install ros-kinetic-octomap

sudo apt-get install ros-kinetic-octomap-ros

sudo apt-get install ros-kinetic-octomap-server
```
>sbpl을 설치한다.
```
cd ~/docker_share/catkin_ws/src

git clone https://github.com/sbpl/sbpl.git

cd sbpl

mkdir build

cd build

cmake ..

make

sudo make install
```
>humanoid navigation을 마저 설치한다.
>> ! catkin_make 중 humanoid_localization.cpp build에서 pcl/filters/uniform_sampling.h: No such file or directory 애러가 발생할수도 있는데 이는 op3가 pcl의 옛날 uniform_sampling의 패키지의 위치를 참조하기 때문에 발생하는 일임.  
>> ! catkin_ws/src/humanoid_navigation/humanoid_localization/src/HumanoidLocalization.cpp를 gedit으로 열고 #include <pcl/filters/uniform_sampling.h>을 #include <pcl/keypoints/uniform_sampling.h>로 고치자
```
cd ~/docker_share/catkin_ws/src

git clone https://github.com/ROBOTIS-GIT/humanoid_navigation.git

cd ~/docker_share/catkin_ws

catkin_make
```
>web_setting tools를 위한 패키지를 설치한다.
```
sudo apt install ros-kinetic-rosbridge-server ros-kinetic-web-video-server
```
>Robotis op3 Robotpackages를 설치하자
>> !catkin_make 중 Robotis-OP3-Tools에서 action_editor 빌드 오류가 날 수도 있는데 깔끔하게 이 레포지스토리에 있는 ROBOTIS-OP3-Tools로 교체하면 해결된다.
```
cd ~/docker_share/catkin_ws/src

git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-Framework.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-Framework-msgs.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-Math.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-OP3.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-OP3-Demo.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-OP3-msgs.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-OP3-Tools.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-OP3-Common.git

git clone https://github.com/ROBOTIS-GIT/ROBOTIS-Utility.git

cd ~/docker_share/catkin_ws

catkin_make
```
>설치가 끝났다면 도커 컨테이너 이미지 파일로 저장해야 되는거 잊지 말자!


## 3. 쉬운 코드 편집 작업을 위한 VScode 설치(host)(VScode는 jetson 설치 기준입니다. 일반 데스크톱은 직접 검색할 것!)
>참고 주소: https://opencourse.tistory.com/221  
>참고 주소: https://mylogcenter.tistory.com/7  
>참고 주소: https://makingrobot.tistory.com/83  
>설치
```
1. https://github.com/toolboc/vscode/releases에서 release 다운로드
2. 다운이 완료되면 다음 명령어로 설치진행 sudo dpkg -i code-oss_1.32.3-arm64.deb   
```
>파이썬 편집을 위한 세팅(필수 아님)(하지만 하면 좋음)
  1. VScode로 들어간다.
  2. Extension에서 python 설치
  3. Visual Studio IntelliCode 설치
  4. Python for VSCode 설치
  5. Python Extension Pack 설치
  6. code Runner 설치
>이제 cpp파일을 열거나 python 파일등 문서 파일을 열 때 code-oss 파일이름 을 치시면 됩니다.  
>cpp 위주로 편집하신다면 파이썬 편집을 위한 세팅 대신 검색하셔서 알맞은 환경 세팅을 부탁드립니다.  
>http://wanochoi.com/?p=4643에 따라 pycharm을 설치한다면 pycharm 실행 명령어는 다음과 같습니다.  
>sudo pycharm.sh  
>pycharm을 설치하시고 인터프리터 연결을 python 가상환경과 연결하면 자동 완성 기능 사용가능
---
