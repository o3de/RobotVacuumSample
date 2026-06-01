# Docker scripts for running the O3DE Robot Vacuum Sample

This directory contains a Dockerfile and helper scripts for building and running the O3DE Robot Vacuum Sample project.
The Docker image is based on Ubuntu 24.04 (Noble) with ROS 2 Jazzy.

> **Note:** The O3DE simulation is also compatible with Ubuntu 22.04 and ROS 2 Humble.
> However, the navigation launch files have been updated for ROS 2 Jazzy and would need to be reverted for Humble.
> See [Humble compatibility](#humble-compatibility) for details.

## Prerequisites

* [Hardware requirements of O3DE](https://www.o3de.org/docs/welcome-guide/requirements/)
* At least 60 GB of free disk space
* Docker installed and configured
  * **Note:** It is recommended to have Docker installed correctly and in a secure manner so that the Docker commands in this guide do not require elevated privileges (sudo). See [Docker Engine post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) for more details.
* [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

## Building the Docker Image

By default, the Dockerfile builds a simulation image for Ubuntu 24.04 (Noble) with ROS 2 Jazzy.
All Docker commands below should be run from the `Docker/` directory:

```shell
cd Docker
docker build -t o3de_robot_vacuum_simulation:latest .
```

This creates a Docker image named `o3de_robot_vacuum_simulation` that contains the simulation launcher,
the navigation stack, and helper scripts (`LaunchSimulation.bash` and `LaunchNavStack.bash`).

You can also create a separate image that contains only the navigation stack and RViz2:

```shell
docker build --build-arg IMAGE_TYPE=navstack -t o3de_robot_vacuum_navstack:latest .
```

## Running the Docker Image

Launching O3DE applications in a Docker container requires GPU acceleration support.
Make sure the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) is installed.

### Step 1 — Allow display access

```shell
xhost +local:root
```

### Step 2 — Launch the simulation

```shell
docker run --rm --network=host --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  o3de_robot_vacuum_simulation:latest \
  /data/workspace/LaunchSimulation.bash
```

### Step 3 — Launch the navigation stack

Once the simulation is running, start the navigation stack in a second terminal.
You can use the same simulation image:

```shell
docker run --rm --network=host --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  o3de_robot_vacuum_simulation:latest \
  /data/workspace/LaunchNavStack.bash
```

Or the dedicated navstack image if you built one separately:

```shell
docker run --rm --network=host --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  o3de_robot_vacuum_navstack:latest \
  /data/workspace/LaunchNavStack.bash
```

### Step 4 — Revoke display access when done

```shell
xhost -local:root
```

> **Note:** `--network=host` is recommended over `--network=bridge` to avoid ROS 2 multicast routing issues between containers on the same machine.

## Advanced Options

### Custom SDK installer

| Argument       | Description                      | Default                                                      |
|----------------|----------------------------------|--------------------------------------------------------------|
| `O3DE_DEB_URL` | URL of the O3DE SDK `.deb` file  | `https://o3debinaries.org/main/Latest/Linux/o3de_2605_0.deb` |

### Custom source repositories and branches

| Argument                | Repository               | Default                                            |
|-------------------------|--------------------------|----------------------------------------------------|
| `LOFT_GEM_REPO`         | Loft ArchVis Scene Gem   | `https://github.com/o3de/loft-arch-vis-sample.git` |
| `ROBOT_VAC_SAMPLE_REPO` | Robot Vacuum Sample      | `https://github.com/o3de/RobotVacuumSample.git`    |

| Argument                  | Repository               | Default |
|---------------------------|--------------------------|---------|
| `LOFT_GEM_BRANCH`         | Loft ArchVis Scene Gem   | `main`  |
| `ROBOT_VAC_SAMPLE_BRANCH` | Robot Vacuum Sample      | `main`  |

## Humble compatibility

The O3DE simulation is also compatible with Ubuntu 22.04 and ROS 2 Humble. However, the navigation launch files
in the `launch/` directory have been updated for ROS 2 Jazzy in two ways:

- Plugin names in `launch/config/navigation_params.yaml` use the `::` separator (e.g., `nav2_navfn_planner::NavfnPlanner`), while Humble expects `/` (e.g., `nav2_navfn_planner/NavfnPlanner`).
- The `recoveries_server` node (Humble) was replaced by `behavior_server` (Jazzy) in the same file.

To use Humble, change the Dockerfile defaults and revert those names in `navigation_params.yaml`:

```shell
docker build \
  --build-arg ROS_VERSION=humble \
  --build-arg UBUNTU_VERSION=jammy \
  -t o3de_robot_vacuum_simulation:humble .
```
