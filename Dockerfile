FROM ubuntu:18.04

RUN apt update \
  && apt install -y --no-install-recommends \
     locales \
     software-properties-common tzdata \
  && locale-gen en_US en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && add-apt-repository universe

ENV LANG en_US.UTF-8
ENV TZ=Asia/Tokyo

RUN apt update \
    && apt install -y --no-install-recommends \
       curl gnupg2 lsb-release python3-pip vim wget build-essential ca-certificates

#Install ROS melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && apt install curl \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-get -y update \
    && apt-get -y install ros-melodic-desktop-full  \ 
    && echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc \
    && ["/bin/bash", "-c", "source ~/.bashrc"]
    && apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential \
    && apt install -y python-rosdep \
    && rosdep init \
    && rosdep update

#Install python-catkin-tools
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
    && wget http://packages.ros.org/ros.key -O - | sudo apt-key add - \
    && apt-get update \
    && apt-get install python-catkin-tools

#Install velodyne 
RUN apt-get install ros-melodic-velodyne

#Install pcl
RUN apt-get install ros-melodic-perception-pcl

#Rosdep
RUN cd /ros_melodic_ws/src \
    && rosdep install --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y

# Add user and group
ARG UID
ARG GID
ARG USER_NAME
ARG GROUP_NAME

RUN groupadd -g ${GID} ${GROUP_NAME}
RUN useradd -u ${UID} -g ${GID} -s /bin/bash -m ${USER_NAME}

USER ${USER_NAME}

WORKDIR /ros_melodic_ws

CMD ["/bin/bash"]