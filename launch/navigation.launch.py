#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

import pathlib

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node


def generate_launch_description():

    slam_launch_file = pathlib.Path(__file__).parent.absolute().joinpath('slam.launch.py')

    navigation_launch_file = pathlib.Path(
        get_package_share_directory("nav2_bringup")).joinpath(
            'launch', 'navigation_launch.py')

    navigation_param_file = pathlib.Path(__file__).parent.absolute().joinpath(
        'config', 'navigation_params.yaml')

    rviz_config_file = pathlib.Path(__file__).parent.absolute().joinpath(
        'config', 'config.rviz')

    return LaunchDescription([
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource([str(slam_launch_file)])
        ),
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource([str(navigation_launch_file)]),
            launch_arguments={
                'params_file': str(navigation_param_file)
            }.items()
        ),
        Node(
            package='rviz2',
            executable='rviz2',
            name='slam',
            output='log',
            arguments=[
                '-d', str(rviz_config_file),
            ]
        ),
    ])
