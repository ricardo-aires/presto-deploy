# Containerised Presto

This project provides a way to run [Presto](https://prestodb.io) in containers.

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

There are three different deployments:

- Standalone - only one node to act as discovery, coordinator and worker.
- Cluster - one node to act as discovery and coordinator other nodes as workers.
- Cluster with External Discovery Server - one node to act as discover, one other to be the coordinator and other nodes to act as workers.

> The last one requires a Discovery Server to be in-place a [Dockerfiles](https://docs.docker.com/engine/reference/builder/) to build the required image will be also provided.

## Dockerfiles

In that case we will provide two [Dockerfiles](https://docs.docker.com/engine/reference/builder/) to build the required images:

- [Discovery Server](./docker/build/discovery-server/README.md)
- [Presto](./docker/build/presto/README.md)

## Docker Compose

Two [docker-compose files](https://docs.docker.com/compose/compose-file/) will be provided to spin:

- [Presto Cluster](./docker/docker-compose-presto-cluster.yml) - 1 coordinator and 2 workers
- [Presto Cluster with external Discovery Server](./docker/docker-compose-presto-external-discovery.yml) - 1 discovery server, 1 coordinator and 2 workers

We can use them to build the required images also, from this directory just run:

```bash
docker-compose -f ./docker/docker-compose-presto-cluster.yml build
docker-compose -f ./docker/docker-compose-presto-external-discovery.yml build
```

To spin up either one, run:

```bash
docker-compose -f ./docker/docker-compose-presto-cluster.yml up
docker-compose -f ./docker/docker-compose-presto-external-discovery.yml up
```

## Kubernetes

After creating the images we will be able to run it in [Kubernetes](https://kubernetes.io) using two deployments:

- [Presto Cluster](./k8s/k8s-presto-deploy.yml) - 1 coordinator and 2 workers
- [Presto Cluster with external Discovery Server](./k8s/k8s-presto-external-discovery.yml) - 1 discovery server, 1 coordinator and 2 workers

To spin up either one, run:

```bash
kubectl apply -f ./k8s/k8s-presto-deploy.yml
kubectl apply -f ./k8s/k8s-presto-external-discovery.yml
```
