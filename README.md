# O3DE Simulation - Robot Vacuum Sample 

This sample project demonstrates a robotic vacuum simulation project navigating through the O3DE Loft scene using the ROS 2 Gem and the ROS 2 navigation stack.

### Demo video

https://user-images.githubusercontent.com/82551958/229621938-da2244c7-69c1-4240-9f85-f883ccada128.mp4

### Image

![image](https://user-images.githubusercontent.com/16702721/174113203-e22cfd37-1bd5-4e42-a543-17b92de96c13.png)

## Requirements

This project was tested on the following platforms:
- Ubuntu 24.04 with ROS 2 Jazzy

> **Note:** The O3DE simulation is also compatible with Ubuntu 22.04 and ROS 2 Humble.
> However, the navigation launch files have been updated for ROS 2 Jazzy and would need to be reverted for Humble.
> See the [Docker README](Docker/README.md#humble-compatibility) for details.

The ROS 2 Gem is not available for Windows.

Refer to the [O3DE System Requirements](https://www.o3de.org/docs/welcome-guide/requirements/) documentation to make sure that the system/hardware requirements are met

This project has the following dependencies:

- [O3DE](https://github.com/o3de/o3de)
- [ROS2 Gem](https://github.com/o3de/o3de-extras/tree/development/Gems/ROS2)
  - ROS 2 Jazzy itself is also required, see [Gem Requirements](https://github.com/o3de/o3de-extras/tree/development/Gems/ROS2#requirements)
- [Loft Scene Sample](https://github.com/o3de/loft-arch-vis-sample)
  - ` main` branch should work.
- [Robot Vacuum Sample Project](https://github.com/o3de/RobotVacuumSample)
  - `main` branch (the default) should work.

## Setup Instructions

The following steps will assume the following

- The instructions will be based off of a common base folder: $DEMO_BASE (absolute path). For the steps below, we will use DEMO_BASE of ~/ for simplicty. 
- This current project has been fetched to $DEMO_BASE
- You have [ROS 2](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debians.html) installed and sourced:
  - for ROS 2 Jazzy: `source /opt/ros/jazzy/setup.bash`
  - you could also add this line to your `.profile` or `.bashrc`
  - check if ROS 2 is sourced in your current console with `echo $ROS_DISTRO`. You should see `jazzy`.

### 1. Install and register the engine

```shell
wget https://o3debinaries.org/main/Latest/Linux/o3de_2605_0.deb
sudo dpkg -i o3de_2605_0.deb
/opt/O3DE/26.05/python/get_python.sh
/opt/O3DE/26.05/scripts/o3de.sh register --this-engine

```

### 2. Download and register required Gems
```shell
/opt/O3DE/26.05/scripts/o3de.sh register --repo-uri https://canonical.o3de.org
/opt/O3DE/26.05/scripts/o3de.sh download --gem-name LevelGeoreferencing==1.0.0
/opt/O3DE/26.05/scripts/o3de.sh download --gem-name ROS2==4.2.0
/opt/O3DE/26.05/scripts/o3de.sh download --gem-name ROS2Controllers==1.1.0
/opt/O3DE/26.05/scripts/o3de.sh download --gem-name ROS2Sensors==1.0.1
```

### 3. Clone and register the Loft Scene project locally

```shell
cd $DEMO_BASE
git clone https://github.com/o3de/loft-arch-vis-sample.git -b main
cd loft-arch-vis-sample
git lfs install
git lfs pull
/opt/O3DE/26.05/scripts/o3de.sh register -gp $DEMO_BASE/loft-arch-vis-sample/Gems/ArchVis
```

> **Tip:** To reduce download size and disk usage, you can clone only the latest commit by adding `--depth 1` to the clone command:
> ```shell
> git clone https://github.com/o3de/loft-arch-vis-sample.git -b main --depth 1
> ```

### 4. Clone this project and build it

```shell
cd $DEMO_BASE
git clone https://github.com/o3de/RobotVacuumSample.git
cd RobotVacuumSample
git lfs install
git lfs pull
cmake -B build/linux -G "Ninja Multi-Config" -DLY_STRIP_DEBUG_SYMBOLS=TRUE -DLY_DISABLE_TEST_MODULES=ON
cmake --build build/linux --config profile --target RobotVacuumSample RobotVacuumSample.GameLauncher RobotVacuumSample.Assets
```

> **Tip:** To reduce download size and disk usage, you can clone only the latest commit by adding `--depth 1` to the clone command:
> ```shell
> git clone https://github.com/o3de/RobotVacuumSample.git --depth 1
> ```

### 5. Launch the simulation

```shell
cd $DEMO_BASE
./build/linux/bin/profile/RobotVacuumSample.GameLauncher -bg_ConnectToAssetProcessor=0
```

## Running with Docker

As an alternative to the manual setup above, a Docker-based workflow is available in the [`Docker/`](Docker/) directory.
See [Docker/README.md](Docker/README.md) for build and run instructions.

## Running ROS 2 navigation example

We can run ROS 2 navigation stack with our simulation scene and robot. When we run the navigation stack, it will start SLAM and build the map of environment based on Lidar sensor data. You can set navigation goals for the robot using RViz2 (which is also started with the launch file).

- It is assumed that you have your [ROS 2 environment sourced](https://docs.ros.org/en/rolling/Tutorials/Configuring-ROS2-Environment.html).
- It is also assumed that you followed all the steps before and launched the simulation.

### 1. Install dependencies for navigation 

These packages are required to run ROS 2 navigation stack for our robot.

```shell
sudo apt install -y ros-${ROS_DISTRO}-slam-toolbox ros-${ROS_DISTRO}-navigation2 ros-${ROS_DISTRO}-nav2-bringup ros-${ROS_DISTRO}-pointcloud-to-laserscan ros-${ROS_DISTRO}-ackermann-msgs ros-${ROS_DISTRO}-control-toolbox ros-${ROS_DISTRO}-gazebo-msgs
```

### 2. Run the simulation

```shell
cd $DEMO_BASE
./build/linux/bin/profile/RobotVacuumSample.GameLauncher -bg_ConnectToAssetProcessor=0
```

### 3. Run the navigation stack

The launch file is included in this repository

```shell
cd $DEMO_BASE/launch
ros2 launch navigation.launch.py
```

You should see output in the console as well as RViz2 window.

### 4. Set robot target goal

Use RViz GUI to set the goal by using the `2D Goal Pose` tool (upper toolbar). 
You can drag it to indicate direction you would like your robot to face when reaching the goal.

Watch your robot go. You can set subsequent goals.

## Modifying the simulation

To modify the scene, robot, or sensor configuration, launch the O3DE Editor. The Editor also runs the `AssetProcessor` in the background, which processes any changed assets before they appear in the simulation.

```shell
cmake --build build/linux --config profile --target Editor
/opt/O3DE/26.05/bin/Linux/profile/Default/Editor --project-path $DEMO_BASE
```

> **Note:** You might want to start `AssetProcessor` before the first start of the Editor, to ensure all assets are processed first.
> ```shell
> /opt/O3DE/26.05/bin/Linux/profile/Default/AssetProcessor --project-path $DEMO_BASE
> ```

## Troubleshooting

#### AssetProcessor resource problems

Sometimes when there were problems while the `AssetProcessor` was working (for example, disk space ran out),
subsequent executions of the `Editor` fail to re-start the process for such Assets. This might be due to a
limitation of the number of files that can be watched by a single user. You can fix this by increasing the
value, for example:

```shell
sudo sysctl -w fs.inotify.max_user_watches=524288
```

To make this setting permanent, add it to `/etc/systctl.conf` file.

#### No ROS 2 traffic on topics

This could be caused by a firewall, disabled multicast or issues with docker.

Please refer to [ROS 2 troubleshooting guide](https://docs.ros.org/en/rolling/How-To-Guides/Installation-Troubleshooting.html).
