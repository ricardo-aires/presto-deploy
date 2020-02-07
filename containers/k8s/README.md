# Presto in Kubernetes

With the Presto image created [here](../docker/README.md) we may spin a Presto Cluster with one coordinator and several workers.

In this case we are going to show a way to spin with an external Discovery also. We can use [this](https://github.com/ricardo-aires/discovery-server-deploy/tree/master/containers/docker) to build a Discovery Server image.

## Getting started

After building the images just run, from this directory:

```bash
kubectl apply -f ./k8s-presto-deploy.yml
```

It will create:

- A [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for our test
- Two [headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) 
  - one to expose the server port of the Discovery Server in the cluster
  - one to expose the server port of the Prestos, coordinators and workers, in the cluster
- Three [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
  - one for the Discovery Server
  - one for the Presto Coordinator
  - one for multiple Presto Workers

## Considerations

### Variables

The Discovery Server doesn't required any change of variables to run out of the box. In fact, there are only two variables:

- `DISCOVERY_HEAP_SIZE`: heap size to allocate to the service, defaults to 1G.
- `DISCOVERY_ENV`: name of the environment, defaults to docker.

For the Presto Coordinator we need to set the `PRESTO_ROLE` variable to `coordinator` and, because we are using an external Discovery Server, we need to set:

- `IS_DISCOVERY_INTERNAL` - set to `false`.
- `DISCOVERY_SERVER_IP` - which should point to the container runnig the discovery server.

For the `workers` we need to set the `PRESTO_ROLE` variable to `worker` and also change the `DISCOVERY_SERVER_IP`.

Other variables to ease the settings of Presto:

- `PRESTO_HEAP_SIZE`: heap size to allocate to the service, defaults to `2G`.
- `PRESTO_ENV`: name of the environment, defaults to `docker`.
- `PRESTO_QUERY_MAX_MEMORY`: the maximum amount of distributed memory that a query may use, defaults to`1GB`.
- `PRESTO_QUERY_MAX_MEMORY_PER_NODE`: the maximum amount of user memory that a query may use on any one machine, defaults to `1GB`.
- `PRESTO_QUERY_MAX_TOTAL_MEMORY_PER_NODE`: the maximum amount of user and system memory that a query may use on any one machine, defaults to `1GB`.

### Scale

The only `StatefulSet` able to scale is the `worker`.
