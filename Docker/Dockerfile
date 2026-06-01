# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

ARG ROS_VERSION=jazzy
ARG UBUNTU_VERSION=noble

FROM ros:${ROS_VERSION}-ros-base-${UBUNTU_VERSION}

ARG ROS_VERSION
ARG UBUNTU_VERSION

# Argument to determining the image type ('simulation' or 'navstack')
ARG IMAGE_TYPE=simulation

# O3DE SDK installer URL and install path
ARG O3DE_DEB_URL=https://o3debinaries.org/main/Latest/Linux/o3de_2605_0.deb
ARG O3DE_INSTALL_DIR=/opt/O3DE/26.05

ARG LOFT_GEM_REPO=https://github.com/o3de/loft-arch-vis-sample.git
ARG LOFT_GEM_BRANCH=main

ARG ROBOT_VAC_SAMPLE_REPO=https://github.com/o3de/RobotVacuumSample.git
ARG ROBOT_VAC_SAMPLE_BRANCH=main

ENV WORKSPACE=/data/workspace

WORKDIR $WORKSPACE

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends wget curl

# Install build tools, O3DE system dependencies, and ROS 2 navigation packages
RUN apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        clang \
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
        libssl-dev \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-randr0 \
        ufw \
        ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-slam-toolbox \
        ros-${ROS_DISTRO}-navigation2 \
        ros-${ROS_DISTRO}-nav2-bringup \
        ros-${ROS_DISTRO}-pointcloud-to-laserscan \
        ros-${ROS_DISTRO}-gazebo-msgs \
        ros-${ROS_DISTRO}-ackermann-msgs \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
        ros-${ROS_DISTRO}-control-toolbox \
        ros-${ROS_DISTRO}-vision-msgs \
        ros-${ROS_DISTRO}-nav-msgs

# Download and install the O3DE SDK
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        wget -O /tmp/o3de_latest.deb ${O3DE_DEB_URL} && \
        apt-get install -y /tmp/o3de_latest.deb && \
        rm /tmp/o3de_latest.deb; \
    fi

# Initialize O3DE Python environment, register the engine, and download required Gems
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        ${O3DE_INSTALL_DIR}/python/get_python.sh && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh register --this-engine && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh register --repo-uri https://canonical.o3de.org && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh download --gem-name LevelGeoreferencing && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh download --gem-name ROS2 && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh download --gem-name ROS2Controllers && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh download --gem-name ROS2Sensors; \
    fi

# Clone and register the Loft Scene Gem
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        git clone ${LOFT_GEM_REPO} --depth 1 -b ${LOFT_GEM_BRANCH} $WORKSPACE/loft-arch-vis-sample && \
        git -C $WORKSPACE/loft-arch-vis-sample lfs install && \
        git -C $WORKSPACE/loft-arch-vis-sample lfs pull && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh register -gp $WORKSPACE/loft-arch-vis-sample/Gems/ArchVis; \
    fi

# Clone and register the Robot Vacuum Sample project
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        git clone ${ROBOT_VAC_SAMPLE_REPO} --depth 1 -b ${ROBOT_VAC_SAMPLE_BRANCH} $WORKSPACE/RobotVacuumSample && \
        git -C $WORKSPACE/RobotVacuumSample lfs install && \
        git -C $WORKSPACE/RobotVacuumSample lfs pull && \
        ${O3DE_INSTALL_DIR}/scripts/o3de.sh register -pp $WORKSPACE/RobotVacuumSample; \
    elif [ "${IMAGE_TYPE}" = "navstack" ]; then \
        git clone --depth 1 -b ${ROBOT_VAC_SAMPLE_BRANCH} ${ROBOT_VAC_SAMPLE_REPO} $WORKSPACE/RobotVacuumSample; \
    else \
        echo "Unsupported IMAGE_TYPE: ${IMAGE_TYPE}" && exit 1; \
    fi

# Build the project
RUN if [ "${IMAGE_TYPE}" = "simulation" ]; then \
        . /opt/ros/${ROS_DISTRO}/setup.sh && \
        cmake -B $WORKSPACE/RobotVacuumSample/build/linux \
              -S $WORKSPACE/RobotVacuumSample \
              -G "Ninja Multi-Config" \
              -DLY_STRIP_DEBUG_SYMBOLS=TRUE \
              -DLY_DISABLE_TEST_MODULES=ON && \
        cmake --build $WORKSPACE/RobotVacuumSample/build/linux \
              --config profile \
              --target RobotVacuumSample RobotVacuumSample.GameLauncher RobotVacuumSample.Assets; \
    fi

# Remove source files to reduce the image size
RUN rm -rf $WORKSPACE/loft-arch-vis-sample
RUN rm -rf ~/.o3de/3rdParty/

COPY LaunchSimulation.bash /data/workspace/LaunchSimulation.bash
COPY LaunchNavStack.bash /data/workspace/LaunchNavStack.bash

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV LAUNCH_FULLSCREEN_OPT=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

ENTRYPOINT ["/bin/bash", "-c"]
