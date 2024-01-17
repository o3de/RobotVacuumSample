# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

# Collect the arguments for the base ros image
ARG ROS_VERSION=humble
ARG UBUNTU_VERSION=jammy

FROM ros:${ROS_VERSION}-ros-base-${UBUNTU_VERSION}

ARG ROS_VERSION
ARG UBUNTU_VERSION


# Argument to determining the image type ('simulation' or 'navstack')
ARG IMAGE_TYPE=simulation  # Default to 'simulation'

# Arguments for the source repos needed for the robot vacuum sample docker
ARG O3DE_REPO=https://github.com/o3de/o3de.git
ARG O3DE_BRANCH=2310.1

ARG O3DE_EXTRAS_REPO=https://github.com/o3de/o3de-extras.git
ARG O3DE_EXTRAS_BRANCH=2310.1

ARG LOFT_GEM_REPO=https://github.com/o3de/loft-arch-vis-sample.git
ARG LOFT_GEM_BRANCH=main

ARG ROBOT_VAC_SAMPLE_REPO=https://github.com/o3de/RobotVacuumSample.git
ARG ROBOT_VAC_SAMPLE_BRANCH=main

# Additional argument to control build concurrency
ARG CMAKE_JOBS=8

ENV WORKSPACE=/data/workspace

WORKDIR $WORKSPACE

RUN apt-get update && apt-get upgrade -y

# Add additional package repositories needed for packages
RUN apt-get install -y --no-install-recommends gpg wget curl


# For ubuntu 20.04 (focal) then default version of cmake is not supported. Update and get version 3.24.1 from kitware
RUN if [ "${UBUNTU_VERSION}" = "focal" ]; then \
      wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
        gpg --dearmor - | \
        tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
      && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | \
        tee /etc/apt/sources.list.d/kitware.list >/dev/null \
      && apt-get update; \
    fi

#
# Install packages needed for cloning and building from the source repos
#

# Install the git and build tools
RUN apt-get install -y --no-install-recommends git \
                       git-lfs \
                       clang-12 \
                       ninja-build \
                       cmake \
                       libglu1-mesa-dev \
                       libxcb-xinerama0 \
                       libxcb-xinput0 \
                       libxcb-xinput-dev \
                       libxcb-xfixes0-dev \
                       libxcb-xkb-dev \
                       libxkbcommon-dev \
                       libxkbcommon-x11-dev \
                       libfontconfig1-dev \
                       libcurl4-openssl-dev \
                       libsdl2-dev \
                       zlib1g-dev \
                       mesa-common-dev \
                       libssl-dev libxcb-icccm4 \
                       libxcb-image0 \
                       libxcb-keysyms1 \
                       libxcb-render-util0 \
                       libxcb-randr0 \
                       libnvidia-gl-470 \
                       ufw \
                       ros-${ROS_DISTRO}-slam-toolbox \
                       ros-${ROS_DISTRO}-navigation2 \
                       ros-${ROS_DISTRO}-nav2-bringup \
                       ros-${ROS_DISTRO}-pointcloud-to-laserscan \
                       ros-${ROS_DISTRO}-gazebo-msgs \
                       ros-${ROS_DISTRO}-ackermann-msgs \
                       ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
                       ros-${ROS_DISTRO}-control-toolbox \
                       ros-${ROS_DISTRO}-nav-msgs 

COPY cleanup.bash /data/workspace/cleanup.bash

# Clone O3DE repos, register, build, and cleanup in the same layer to reduce the size
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        apt-get install -y --no-install-recommends ros-${ROS_DISTRO}-desktop && \
        cd $WORKSPACE && \
        git clone $O3DE_REPO && \
        git -C $WORKSPACE/o3de checkout $O3DE_BRANCH &&\
        git -C $WORKSPACE/o3de lfs install && \
        git -C $WORKSPACE/o3de lfs pull && \
        $WORKSPACE/o3de/python/get_python.sh && \
        $WORKSPACE/o3de/scripts/o3de.sh register -ep $WORKSPACE/o3de && \
        git clone $O3DE_EXTRAS_REPO && \
        git -C $WORKSPACE/o3de-extras checkout $O3DE_EXTRAS_BRANCH &&\
        $WORKSPACE/o3de/scripts/o3de.sh register -gp $WORKSPACE/o3de-extras/Gems/ROS2 && \
        git clone $LOFT_GEM_REPO && \
        git -C $WORKSPACE/loft-arch-vis-sample checkout $LOFT_GEM_BRANCH &&\
        git -C $WORKSPACE/loft-arch-vis-sample lfs install && \
        git -C $WORKSPACE/loft-arch-vis-sample lfs pull && \
        $WORKSPACE/o3de/scripts/o3de.sh register -gp $WORKSPACE/loft-arch-vis-sample/Gems/ArchVis/ && \
        git clone $ROBOT_VAC_SAMPLE_REPO && \
        git -C $WORKSPACE/RobotVacuumSample checkout $ROBOT_VAC_SAMPLE_BRANCH &&\
        git -C $WORKSPACE/RobotVacuumSample lfs install && \
        git -C $WORKSPACE/RobotVacuumSample lfs pull && \
        $WORKSPACE/o3de/scripts/o3de.sh register -pp $WORKSPACE/RobotVacuumSample/  && \
        . /opt/ros/${ROS_VERSION}/setup.sh && \
        cmake -B $WORKSPACE/RobotVacuumSample/build/linux -S $WORKSPACE/RobotVacuumSample -G "Ninja Multi-Config" -DLY_STRIP_DEBUG_SYMBOLS=TRUE -DLY_DISABLE_TEST_MODULES=ON && \
        cmake --build $WORKSPACE/RobotVacuumSample/build/linux --config profile --target AssetProcessorBatch RobotVacuumSample.GameLauncher RobotVacuumSample.Assets -j $CMAKE_JOBS && \
        $WORKSPACE/cleanup.bash; \
    elif [  "${IMAGE_TYPE}" = "navstack" ]; then \
        apt-get install -y --no-install-recommends ros-${ROS_DISTRO}-desktop && \
        cd $WORKSPACE && \
        git clone --recursive $ROBOT_VAC_SAMPLE_REPO && \
        git -C $WORKSPACE/RobotVacuumSample checkout $ROBOT_VAC_SAMPLE_BRANCH; \
    else \
        echo "Unsupported IMAGE_TYPE: ${IMAGE_TYPE}" && exit 1; \
    fi

COPY LaunchSimulation.bash /data/workspace/LaunchSimulation.bash
COPY LaunchNavStack.bash /data/workspace/LaunchNavStack.bash

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp 
ENV LAUNCH_FULLSCREEN_OPT=0
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
 
ENTRYPOINT ["/bin/bash", "-c"]
