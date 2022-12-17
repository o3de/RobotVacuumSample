#!/bin/bash

# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

# Delete files that were only needed for the Client and AssetProcessing after a build of the code and assets are complete

DELETE_LIST=(o3de-extras/ \
             loft-arch-vis-sample/ \
             ~/.o3de/3rdParty/ \
             o3de/.git \
             o3de/AutomatedTesting \
             o3de/python/downloaded_packages \
             o3de/Code \
             o3de/Gems \
             RobotVacuumSample/.git \
             RobotVacuumSample/Gem \
             RobotVacuumSample/Source \
             RobotVacuumSample/Levels \
             RobotVacuumSample/ReflectionProbes \
             RobotVacuumSample/build/linux/Azcg/ \
             RobotVacuumSample/build/linux/CMake \
             RobotVacuumSample/build/linux/CMakeFiles/ \
             RobotVacuumSample/build/linux/External/ \
             RobotVacuumSample/build/linux/Testing/ \
             RobotVacuumSample/build/linux/_deps/ \
             RobotVacuumSample/build/linux/cmake \
             RobotVacuumSample/build/linux/lib/ \
             RobotVacuumSample/build/linux/o3de/ \
             RobotVacuumSample/build/linux/packages/ \
             RobotVacuumSample/build/linux/runtime_dependencies/ \
             RobotVacuumSample/build/linux/bin/profile/*.Editor.so \
             RobotVacuumSample/build/linux/bin/profile/EditorPlugins \
             RobotVacuumSample/build/linux/bin/profile/Editor \
             RobotVacuumSample/build/linux/bin/profile/AssetProcessor \
             RobotVacuumSample/build/linux/bin/profile/AssetProcessorBatch \
             RobotVacuumSample/build/linux/bin/profile/MaterialEditor \
             RobotVacuumSample/build/linux/bin/profile/AssetBuilder \
             RobotVacuumSample/build/linux/bin/profile/MaterialCanvas )

for i in ${DELETE_LIST[@]}
do
   echo "Deleting /data/workspace/$i"
   rm -rf $i
done

exit 0

