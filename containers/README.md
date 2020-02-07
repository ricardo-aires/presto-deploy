# Containerised Presto

This project provides a way to run [Presto](https://prestodb.io) in containers.

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

There are three different deployments:

- Standalone - only one node to act as discovery, coordinator and worker.
- Cluster - one node to act as discovery and coordinator other nodes as workers.
- Cluster with External Discovery Server - one node to act as discover, one other to be the coordinator and other nodes to act as workers.

> The last one requires a Discovery Server to be in-place a [Dockerfiles](https://docs.docker.com/engine/reference/builder/) to build the required image is provided in this [repo](https://github.com/ricardo-aires/discovery-server-deploy/blob/master/containers/docker/README.md).

## Dockerfiles

In that case we will provide a [Dockerfile](https://docs.docker.com/engine/reference/builder/) to build the Presto image [here](./docker/README.md)

## Docker Compose

A [docker-compose file](https://docs.docker.com/compose/compose-file/) to show case the deployment of a Presto Cluster with an external Discovery Server is available [here](./docker/docker-compose-presto-external-discovery.yml).

We can use it to build the Presto images also, from switch to `./docker/` directory and run:

```bash
docker-compose build
```

To spin up, run:

```bash
docker-compose up
```

## Kubernetes

After creating the images we will be able to run it in [Kubernetes](https://kubernetes.io).

We show an example to setup a Presto Cluster with an external Discovery Server [here](./k8s/README.md)
