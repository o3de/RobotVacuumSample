# O3DE Simulation - Robot Vacuum Sample 

This sample project demonstrates a robotic vacuum simulation project navigating through the O3DE Loft scene using the ROS 2 Gem and the ROS 2 navigation stack.

### Demo video

https://user-images.githubusercontent.com/82551958/229621938-da2244c7-69c1-4240-9f85-f883ccada128.mp4

### Image

![image](https://user-images.githubusercontent.com/16702721/174113203-e22cfd37-1bd5-4e42-a543-17b92de96c13.png)

## Requirements

This project will run on 
- Ubuntu 20.04 with ROS 2 Galactic
- Ubuntu 22.04 with ROS 2 Humble

The ROS 2 Gem is not yet developed for Windows. 

Refer to the [O3DE System Requirements](https://www.o3de.org/docs/welcome-guide/requirements/) documentation to make sure that the system/hardware requirements are met

This project has the following dependencies:

- [O3DE](https://github.com/o3de/o3de)
- [ROS2 Gem](https://github.com/o3de/o3de-extras/tree/development/Gems/ROS2)
  - ROS 2 (Galactic or Humble) itself is also required, see [Gem Requirements](https://github.com/o3de/o3de-extras/tree/development/Gems/ROS2#requirements)
- [Loft Scene Sample](https://github.com/o3de/loft-arch-vis-sample)
  - ` main` branch should work.
- [Robot Vacuum Sample Project](https://github.com/o3de/RobotVacuumSample)
  - `main` branch (the default) should work.

## Setup Instructions

The following steps will assume the following

- The instructions will be based off of a common base folder: $DEMO_BASE (absolute path). For the steps below, we will use DEMO_BASE of ~/ for simplicty. 
- This current project has been fetched to $DEMO_BASE
- You have [ROS2 Galactic](https://docs.ros.org/en/galactic/Installation/Ubuntu-Install-Debians.html) or [ROS2 Humble](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html) installed and sourced 
  - for debian package Galactic installation, in your bash console, run:
     - For ROS2 Galactic: `source /opt/ros/galactic/setup.bash` 
     - For ROS2 Humble: `source /opt/ros/humble/setup.bash`
  - you could also add this line to your `.profile` or `.bashrc`
  - check if ROS 2 is sourced in your current console with `echo $ROS_DISTRO`. You should see `galactic` or `humble`.

### 1. Clone O3DE (or install) and register the engine

```
$ cd $DEMO_BASE
~$ git clone https://github.com/o3de/o3de.git -b main
~$ cd o3de
~/o3de$ git lfs install
~/o3de$ git lfs pull
~/o3de$ python/get_python.sh
~/o3de$ scripts/o3de.sh register --this-engine
```

### 2. Clone and register the ROS2 Gem locally

```
~$ cd $DEMO_BASE
~$ git clone https://github.com/o3de/o3de-extras.git -b main
~$ $DEMO_BASE/o3de/scripts/o3de.sh register -gp $DEMO_BASE/o3de-extras/Gems/ROS2
```

### 3. Clone and register the Loft Scene project locally

```
$ cd $DEMO_BASE
~$ git clone https://github.com/o3de/loft-arch-vis-sample.git -b main
~$ cd loft-arch-vis-sample
~/loft-arch-vis-sample$ git lfs install
~/loft-arch-vis-sample$ git lfs pull
~/loft-arch-vis-sample$ $DEMO_BASE/o3de/scripts/o3de.sh register -gp $DEMO_BASE/loft-arch-vis-sample/Gems/ArchVis
```

### 4. Clone and Register this project and build it

```
$ cd $DEMO_BASE
~$ git clone https://github.com/o3de/RobotVacuumSample.git
~$ cd RobotVacuumSample
~/RobotVacuumSample$ git lfs install
~/RobotVacuumSample$ $DEMO_BASE/o3de/scripts/o3de.sh register -pp .
~/RobotVacuumSample$ cmake -B build/linux -G "Ninja Multi-Config" -DLY_STRIP_DEBUG_SYMBOLS=TRUE -DLY_DISABLE_TEST_MODULES=ON
~/RobotVacuumSample$ cmake --build build/linux --config profile --target RobotVacuumSample Editor AssetProcessor
```

### 5. Launch Editor

```
$ cd $DEMO_BASE
~$ cd RobotVacuumSample/build/linux/bin/profile
~/RobotVacuumSample/build/linux/bin/profile$ ./Editor
```

## Running ROS2 navigation example

We can run ROS2 navigation stack with our simulation scene and robot. When we run the navigation stack, it will start SLAM and build the map of environment based on Lidar sensor data. You can set navigation goals for the robot using RViz2 (which is also started with the launch file).

- It is assumed that you have your [ROS2 environment sourced](https://docs.ros.org/en/rolling/Tutorials/Configuring-ROS2-Environment.html).
- It is also assumed that you followed all the steps before build and launch the Editor.

### 1. Install dependencies for navigation 

These packages are required to run ROS 2 navigation stack for our robot. For ROS 2 Humble, replace `galactic` with `humble`.

```
source /opt/ros/galactic/setup.bash
sudo apt install -y ros-${ROS_DISTRO}-slam-toolbox ros-${ROS_DISTRO}-navigation2 ros-${ROS_DISTRO}-nav2-bringup ros-${ROS_DISTRO}-pointcloud-to-laserscan ros-${ROS_DISTRO}-ackermann-msgs ros-${ROS_DISTRO}-control-toolbox ros-${ROS_DISTRO}-gazebo-msgs
```

### 2. Run the simulation

1. In `O3DE` Editor, select the `Loft` Level.
1. Start simulation by clicking `Play Game` button or press `CTRL+G`

### 3. Run the navigation stack

The launch file is included in this repository

```
~/RobotVacuumSample/launch$ ros2 launch navigation.launch.py
```

You should see output in the console as well as RViz2 window.

### 4. Set robot target goal

Use RViz GUI to set the goal by using the `2D Goal Pose` tool (upper toolbar). 
You can drag it to indicate direction you would like your robot to face when reaching the goal.

Watch your robot go. You can set subsequent goals.

## Troubleshooting

#### AssetProcessor resource problems

Sometimes when there were problems while the AssetProcessor was working (for example, disk space ran out),
subsequent executions of the Editor fail to re-start the process for such Assets. This might be due to a
limitation of the number of files that can be watched by a single user. You can fix this by increasing the
value, for example:

```
sudo sysctl -w fs.inotify.max_user_watches=524288
```

To make this setting permanent, add it to `/etc/systctl.conf` file.

#### No ROS 2 traffic on topics

This could be caused by a firewall, disabled multicast or issues with docker.

Please refer to [ROS 2 troubleshooting guide](https://docs.ros.org/en/rolling/How-To-Guides/Installation-Troubleshooting.html).

#### Memory / resource issues with the scene

If your machine is a bit less powerful, you can try a lightweight, [simple Warehouse scene](https://github.com/RobotecAI/Ros2WarehouseDemo) instead of the Loft scene. 
