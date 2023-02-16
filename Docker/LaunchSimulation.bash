#!/bin/bash

# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

# Check for the optional 'fullscreen' argument
if [ $# -ge 1 ]
then
    if [ "$1" = "fullscreen" ]
    then
        FULLSCREEN_ARG=1
    else
        FULLSCREEN_ARG=0
    fi
else
   FULLSCREEN_ARG=0
fi

export LD_LIBRARY_PATH=/data/workspace/RobotVacuumSample/build/linux/bin/profile:$LD_LIBRARY_PATH

if [ -d /data/workspace/RobotVacuumSample/build/linux/bin/profile ]
then
    cd /data/workspace/RobotVacuumSample/build/linux/bin/profile
    ./RobotVacuumSample.GameLauncher -r_fullscreen=$FULLSCREEN_ARG -bg_ConnectToAssetProcessor=0 > /data/workspace/simulation_launch.log 2>&1
else
    echo "Simulation not installed on this image"
fi

