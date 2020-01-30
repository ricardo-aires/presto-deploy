# Ansible Presto

Roles that will setup  [Presto](https://prestodb.io), an open source, originally developed by Facebook, distributed SQL engine for running fast analytic queries against various data sources.

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

## Architecture

There are three different deployments:

- Standalone - only one node to act as discovery, coordinator and worker.
- Cluster - one node to act as discovery and coordinator other nodes as workers.
- Cluster with External Discovery Server - one node to act as discover, one other to be the coordinator and other nodes to act as workers.

## Roles

Two independent roles were created:

- [discovery-server](discovery-server/README.md) - Role to deploy the discovery service in a separate host.
- [presto-coordinator](presto/README.md) - Role to deploy the Presto 
