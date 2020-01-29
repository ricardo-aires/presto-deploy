# Ansible Presto

Roles that will setup a cluster running [Presto](https://prestodb.io), an open source, originally developed by Facebook, distributed SQL engine for running fast analytic queries against various data sources.

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

## Architecture

The solution provided has the goal to install the discovery service in a dedicated host, a coordinator only host and multiple workers.

## Roles

Three independent roles were created:

- [discovery-server](discovery-server/README.md) - Role to deploy the discovery service in a separate host.
- [presto-coordinator](presto-coordinator/README.md) - Role to deploy the Presto Coordinator in a separate host.
- [presto-worker](presto-worker/README.md) - Role to deploy the Presto Worker.

## Role Variables

## Dependencies

This role doesn't have any dependencies.

## Example Playbook

A working example using Vagrant and Virtual Box is setup under [tests](./tests/).
