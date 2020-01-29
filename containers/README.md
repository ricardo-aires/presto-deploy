# Containerised Presto

[Dockerfiles](https://docs.docker.com/engine/reference/builder/) to build three Docker image with:

- Discovery Server
- Presto Coordinator
- Presto Worker

This will allow us to run [Presto](http://prestodb.io) in containers.

> This was done in a Proof of Concept project, were it wasn't possible to use the [ZooKeeper Docker Official Image](https://hub.docker.com/_/zookeeper).

## Getting Started

In order to build the image just clone the repo to your machine and run [docker build](https://docs.docker.com/engine/reference/commandline/build/) inside each of sub-directories of [build](./build/) where the [Dockerfile](./build/Dockerfile) and [docker-entrypoint.sh](./build/docker-entrypoint.sh) are. Example:

```bash
docker build -t discovery-server:1.0 ./build/discovery-server
```

This can also be done using the [docker-compose file](https://docs.docker.com/compose/compose-file/) found [here](./docker-compose.yml), just run

```bash
docker-compose build
```

### Prerequisities

In order to build the image and run this container you'll need docker installed.

This was tested using [Docker Desktop](https://www.docker.com/products/docker-desktop) for MacOS version 2.1.0.5.

### Base Image

The base image used in this case was the [openjdk:8 Docker Official Image](https://hub.docker.com/_/openjdk). When running inside a organization we should use a base image with:

- java
- python 2.4+
- bash
- wget

### Usage

> ALWAYS give the containers a `hostname` or persistence will not work.

The proper way to run is to use the [docker-compose file](https://docs.docker.com/compose/compose-file/) found [here](./docker-compose.yml) to spin a fully functional cluster with:

- 1x Discovery Server
- 1x Presto Coordinator
- 2x Presto Workers

It will also build the required images.

> This solution was not intentend to run in standalone, and it's not ready for it.

#### Volumes

The only volume exposed in all images is the one for the Discovery Server and Presto Data directoy, at `/data`.

#### Ports

The ports expose are as follow:

- `8441` - for the discovery server
- `8080` - for both Presto Coordinator and Worker

#### Environment Variables

For the discovery server image there is only two variables:

- `DISCOVERY_HEAP_SIZE`: heap size to allocate to the service, defaults to `1G`.
- `DISCOVERY_ENV`: name of the environment, defaults to `docker`.
For the Presto, both Coordinator and worker, the only required variable to be in-place every time is:

- `DISCOVERY_SERVER_IP` - which should point to the container runnig the discovery server.

Other variables to ease the settings of Presto:

- `PRESTO_HEAP_SIZE`: heap size to allocate to the service, defaults to `2G`.
- `PRESTO_ENV`: name of the environment, defaults to `docker`.
- `PRESTO_QUERY_MAX_MEMORY`: the maximum amount of distributed memory that a query may use, defaults to`1GB`.
- `PRESTO_QUERY_MAX_MEMORY_PER_NODE`: the maximum amount of user memory that a query may use on any one machine, defaults to `1GB`.
- `PRESTO_QUERY_MAX_TOTAL_MEMORY_PER_NODE`: the maximum amount of user and system memory that a query may use on any one machine, defaults to `1GB`.

#### Run in Kubernetes

The images may be used in [Kubernetes](https://kubernetes.io) using the [k8s-zookeeper.yml](./k8s-presto-deploy.yml) file:

```bash
kubectl apply -f ./k8s-presto-deploy.yml
```
