# Presto Dockerfile

This project provides a way to run [Presto](https://prestodb.io) in containers.

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

The aim is to provide an image that can support three different deployments:

- Standalone - only one node to act as discovery, coordinator and worker.
- Cluster - one node to act as discovery and coordinator other nodes as workers.
- Cluster with External Discovery Server - one node to act as discover, one other to be the coordinator and other nodes to act as workers.

> The last one requires a Discovery Server to be in-place a [Dockerfiles](https://docs.docker.com/engine/reference/builder/), check [here](../discovery-server/README.md) to build the required image.

## Getting Started

In order to build the image just clone the repo to your machine and run [docker build](https://docs.docker.com/engine/reference/commandline/build/) inside this directory. Example:

```bash
docker build -t presto:1.0 ./
```

To run a simple standalone test:

```bash
docker container run --rm  -p 8080:8080 presto:1.0
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

In order to achieve persistence we must provide a container an `hostname` and a `volume`.

The volume where Presto stores the Data Directory targets `/data`.

```bash
docker container run -p 8080:8080 -v ds-data,/data -h presto --name presto presto:1.0
```

#### Ports

The port `8080` is expose and you may want to publish to connect clients.

#### Environment Variables

By default the `PRESTO_ROLE` variable is set to `standalone`. When running in a cluster you neet to change the value to `coordinator` and `worker` accordingly.

And change the `DISCOVERY_SERVER_IP` to point to the coordinator node.

Other variables to ease the settings of Presto:

- `PRESTO_HEAP_SIZE`: heap size to allocate to the service, defaults to `2G`.
- `PRESTO_ENV`: name of the environment, defaults to `docker`.
- `PRESTO_QUERY_MAX_MEMORY`: the maximum amount of distributed memory that a query may use, defaults to`1GB`.
- `PRESTO_QUERY_MAX_MEMORY_PER_NODE`: the maximum amount of user memory that a query may use on any one machine, defaults to `1GB`.
- `PRESTO_QUERY_MAX_TOTAL_MEMORY_PER_NODE`: the maximum amount of user and system memory that a query may use on any one machine, defaults to `1GB`.

When running with an external Discover Server you must set:

- `IS_DISCOVERY_INTERNAL` - set to `false`.
- `DISCOVERY_SERVER_IP` - which should point to the container runnig the discovery server.
- `DISCOVERY_SERVER_PORT` - which should point to the port of the container runnig the discovery server.
