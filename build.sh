#!/bin/bash

# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# helper script to rebuild project

cmake --build build/linux --config profile --target RobotVacuumSample Editor AssetProcessor -j4