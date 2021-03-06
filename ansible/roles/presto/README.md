# presto

Role that setup  [Presto](https://prestodb.io).

> The solutions provided were designed for Proof of Concepts. Hence, are not to be treated as production ready, especially because of the lack of Security settings.

There are three different deployments:

- Standalone - only one node to act as discovery, coordinator and worker.
- Cluster - one node to act as discovery and coordinator other nodes as workers.
- Cluster with External Discovery Server - one node to act as discover, one other to be the coordinator and other nodes to act as workers.

> The last one needs a Discovery Server to be in-place, under [tests/test_cluster_external_discovery.yml](./tests/test_cluster_external_discovery.yml) we call  the [Discovery Server Role](../discovery-server/README.md).

## Requirements

This role was created using [Ansible 2.9](https://docs.ansible.com/ansible/2.9/) for macOS and tested using the [centos/7](https://app.vagrantup.com/centos/boxes/7) boxes for [Vagrant v.2.2.6](https://www.vagrantup.com/docs/index.html) with [VirtualBox](https://www.virtualbox.org/) as a Provider.

The [Ansible modules](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html) used in the role are:

- [package](https://docs.ansible.com/ansible/latest/modules/package_module.html#package-module)
- [group](https://docs.ansible.com/ansible/2.9/modules/group_module.html#group-module)
- [user](https://docs.ansible.com/ansible/2.9/modules/user_module.html#user-module)
- [file](https://docs.ansible.com/ansible/2.9/modules/file_module.html#file-module)
- [get_url](https://docs.ansible.com/ansible/2.9/modules/get_url_module.html#get_url-module)
- [unarchive](https://docs.ansible.com/ansible/2.9/modules/unarchive_module.html#unarchive-module)
- [copy](https://docs.ansible.com/ansible/2.9/modules/copy_module.html#copy-module)
- [template](https://docs.ansible.com/ansible/2.9/modules/template_module.html#template-module)
- [meta](https://docs.ansible.com/ansible/2.9/modules/meta_module.html#meta_module.html)
- [service](https://docs.ansible.com/ansible/2.9/modules/service_module.html#service-module)

> We are using `systemd` to control the service.

## Role Variables

The next variables are set in [defaults](./defaults/main.yml) in order to be [easily overwrite](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) and fetch a different version:

- `presto_user`: to setup `username`, `group`, `uid` and `gid` for the user to run the service.
- `presto_version`: version of the presto to be installed
- `presto_server_tarball_url_checksum` and `presto_cli_jar_checksum`: if a different version is needed.

Some of the [settings](https://prestodb.io/docs/current/installation/deployment.html) can also be tweaked using variables which also are in [defaults](./defaults/main.yml):

- `presto_http_port`: port used to listen.
- `presto_jvm_max_memory`: heap size to allocate to the service.
- `presto_environment`: name of the environment.
- `presto_query_max_memory`: The maximum amount of distributed memory that a query may use.
- `presto_query_max_memory_per_node`: The maximum amount of user memory that a query may use on any one machine.
- `presto_query_max_total_memory_per_node`: The maximum amount of user and system memory that a query may use on any one machine, where system memory is the memory used during execution by readers, writers, and network buffers, etc.
- `presto_log_level`: Set minimum log level.

Other variables are available in [vars](vars/main.yml), usually don't need to be changed, unless we have a need to use a different mirror, for example.

### Standalone

In order to deploy a standalone Presto the next variable needs to be set:

```bash
presto_is_standalone: true
```

### Cluster

In order to deploy a cluster with one coordinator and several workers, for the workers we need to change:

```bash
presto_is_coordinator: false
```

### Cluster with external Discovery Server

The same change for the previous cluster must also be made for workers:

```bash
presto_is_coordinator: false
```

There are also two variables that must be set accordingly when using an external Discovery Server in all presto nodes (coordinator and workers):

- `discovery_server_ip`: IP address of the Discovery Server host.
- `discovery_server_port`: Port of of the Discovery Server.

## Dependencies

The role itself doesn't depend on other roles, but a Discovery Server must be in-place for the external Discovery scenario.

## Example Playbook

Three working example using Vagrant and Virtual Box are setup under [tests](./tests/).

The [Vagrantfile](./tests/Vagrantfile) will create all necessary VMs for all scenarios, being:

- [Standalone](./tests/test_standalone.yml) - only one node to act as discovery, coordinator and worker.
- [Cluster](./tests/test_cluster.yml) - one node to act as discovery and coordinator and two nodes as workers.
- [Cluster with External Discovery Server](./tests/test_cluster_external_discovery.yml) - one node to act as discover, one other to be the coordinator and two nodes to act as workers.

> Make sure to make the [Discovery Server Role](https://github.com/ricardo-aires/discovery-server-deploy/tree/master/ansible/roles/discovery-server) available in order to run it in the Discovery Server VM.
