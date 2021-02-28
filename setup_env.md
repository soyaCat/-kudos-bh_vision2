# -kudos-bh_vision2
쿠도스 비전 2 설치 방법에 대해 정리한 페이지입니다.

---

# 환경
  - ubuntu18.04
  - jetson의 경우 jetpack 4.4
  
---

# 설정 순서
# ros 이미지 파일 생성
  1. 우분투에 docker를 설치한다.  
  ```
  curl -fsSL https://get.docker.com/ | sudo sh
  
  sudo usermod -aG docker $USER
  
  #다음 명령어로 도커 설치를 확인한다.
  #docker version
  #또는 sudo docker version
  ```
>원한다면 docker를 관리하기 쉽게 만들어준다.  
> docker info | grep Root로 이미지 저장 경로를 확인 할 수 있다.
>```
>docker info | grep Root
>```
>/lib/systemd/system/docker.service을 수정해준다. 
>```
>sudo gedit /lib/systemd/system/docker.service
>```
>파일 14라인에 --data-root 옵션으로 새로운 저장 경로를 설정한다.
>```
>ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/home/soya/docker/docker_build/
>```
>도커를 재부팅한다.
>```
>service docker stop
>service docker start
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
  
  2. 원하는 경로에 ros-docker2폴더를 둔다.  
  3. 터미널에서 ros-docker2로 들어간뒤 build.sh파일을 실행시켜준다.
  ```
  ./build.sh
  ```
  4. 생성된 이미지를 확인한다. 아마 travis/kinetic라는 이미지가 생성되었을 것이다.  
  5. run-docker.sh파일을 보면 중간에 있는 if바로 밑에 IMAGE='ros_kinect_full'이라 되어있을 텐데 이걸 'travis/kinetic:dev'로 바꾸어 준다.
  6. run-docker.sh파일을 실행시켜준다.
  7. 그러면 실행 터미널에서 이미지를 가지고 컨테이너를 만들어 접속한다.
  8. ls치면 docker_share이라는 폴더가 보일텐데 호스트 컴퓨터와 컨테이너 이미지가 공동으로 사용하는 폴더라 생각하면 된다. 이 폴더 아래에 catkin_ws를 설정해야함을 주의하자
  9. 이제 본격적으로 ros를 설치한다.
  ```
  sudo apt-get install -y chrony ntpdate
  
  sudo ntpdate -q ntp.ubuntu.com
  
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
  
  mkdir -p /catkin_ws/src
  
  cd catkin_ws/src
  
  catkin_init_workspace
  
  cd ..
  
  catkin_make
  
  source ~/docker_share/catkin_ws/devel/setup.bash
  ```
  10. roscore를 실행시켜보고 잘 되면 ctrl+C로 나간다.
  11. gedit을 깐다.
  12. 다음 명령을 입력한다.
  ```
  source /opt/ros/kinetic/setup.bash
  source ~/docker_share/catkin_ws/devel/setup.bash
  ```
  13. gedit ~/.bashrc을 실행 시켜 다음의 내용을 삽입한다.(비슷해보이는 부분이 있을텐데 지우거나 수정하면 된다.)
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
  
  14.컨테이너는 휘발성이기 때문에 docker_share안의 내용물을 제외하고는 종료했다가 다시 실행하면 그 내역이 모두 날아가게된다. roscore 실행을 확인했다면 그 컨테이너를 이미지로 저장해준다.(위에 하는 방법 적혀있음), 나는 ros_kinect_full로 이미지 파일 이름을 통일할 것이기 때문에 이미지 파일 이름을 똑같이 해주면 편할 것이다. 이미지 파일로 만들어주고 run-docker.sh의 실행시킬 이미지를 ros_kinect_full로 다시 돌려놓으면 ros설치는 종료다.
  15. ros의 사용법은 큰 차이는 없다. 가장 큰 차이라면 호스트의 터미널을 실행시켰다면 ./run-docker.sh를 이용하여 컨테이너 터미널로 만들어주어야한다는 사실 정도이다. 터미널 4개를 틀고 각각 ./run-docker.sh을 실행시켜 준 후 각 터미널에 다음 명령을 입력하여 ros의 최종 설치를 확인한다.
```
#터미널1
roscore

#터미널2
rosrun turtlesim turtlesim_node

#터미널3
rosrun turtlesim turtle_teleop_key

#터미널4
rqt_graph 
```

---
