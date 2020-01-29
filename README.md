# Presto

[Presto](https://prestodb.io) is an open source, originally developed by Facebook, distributed SQL engine for running fast analytic queries against various data sources.

![Presto](./img/presto.png)

Presto allows querying data where it lives, including Hive, Cassandra, relational databases or even proprietary data stores. A single Presto query can combine data from multiple sources, allowing for analytics across your entire organization.

In this repository we will provide some examples of deploying a Presto Cluster:

- [Ansible](./ansible/roles/README.MD)
- [Docker/Kubernetes](./containers/README.MD)

The distribution in use will be the one from the [Presto Foundation](https://github.com/prestodb/presto).

Being the other one the community managed version of Presto by the [Presto Software Foundation](https://prestosql.io), find more info [here](https://github.com/prestosql/presto) and the artifact [here](https://mvnrepository.com/artifact/io.prestosql/presto-sqlserver).

## Architecture

Presto is a distributed system that runs on one or more machines to form a cluster.

An installation will, tipically, include:

- one Presto Coordinator - Machine to which users submit their queries. The Coordinator is responsible for parsing, planning, and scheduling query execution across the Presto Workers. Usually runs the discovery service in embedded mode.
- any number of Presto Workers - Adding more Presto Workers allows for more parallelism and faster query processing.

Queries are submitted from a client such as the Presto CLI to the coordinator.

Presto doesn't have, at this time, HA. For these reason, and because the ultimate goal is to run it in containers we are going to deploy a slightly different architecture, using a dedicated server to run the discover service.

For this we are going to use the latest [discovery-server](https://repo1.maven.org/maven2/com/facebook/airlift/discovery/discovery-server/1.30/discovery-server-1.30.tar.gz) found in the [Facebook Maven](https://repo1.maven.org/maven2/com/facebook/airlift/discovery/discovery-server)

## Requirements

Presto is written in Java and requires a Java JVM to be installed on your system. Presto often requires a recent update of the latest major release. You should always refer to the [Presto repository](https://github.com/prestodb/presto) for the latest Java requirements.

> At the time: Java 8 Update 161 or higher (8u161+), 64-bit. Both [Oracle JDK](https://www.oracle.com/java/) and [OpenJDK](https://openjdk.java.net/) are supported.

Python 2.4+ is also required.

## Installing

We will use the latest available [tarball](https://repo1.maven.org/maven2/com/facebook/presto/presto-server/0.230/presto-server-0.230.tar.gz) from the [Facebook Presto Maven](https://mvnrepository.com/artifact/com.facebook.presto/presto-server).

Once extracted, it will create a single top-level directory, referred to as the installation directory, that contains:

- `lib/`, contains the the JARs that make up the Presto Server.
- `plugins/`, Presto plugin JARs.
- `bin/`, contains helper launcher scripts to start, stop, restart, kill and get the status of a running Presto process.
- `etc/`, the configuration directory, it is created by the user and provide the necessary configurations needed by Presto.
- `var/`, data directory, the place where logs are stored and it is created the first time Presto Server is launched.

> By default the data directory it’s located in the installation directly, but it is recommended to configure it outside, to allow for the data to be preserved across upgrades.

## Configuration

Before running Presto, we need to provide a set of configuration files:

- Presto Server Configuration
- Presto Catalog Configuration
- Presto Logging Configuration
- Presto Node Configuration
- Java Virtual Machine (JVM) Configuration

These configurations must exist on every machine where Presto runs and, by default, the configuration files are expected to be located in an `etc` directory inside the installation directory.

### Presto Server Configuration

The configuration for the Presto Server resides in the `etc/config.properties`. Keep in mind that a Presto Server can function as a coordinator or a worker, or even both.
But, it is recommended to dedicate a a single machine to only perform coordinator work for best performance.

The basic Presto Server Configuration properties are:

- `coordinator` - setup the Presto instance to function as a coordinator.
- `node-scheduler.include-coordinator` - allow scheduling work on the coordinator.
- `http-server.http.port` - setup the port for the HTTP server, for all communication, internal and external.
- `query.max-memory` - maximum amount of distributed memory that a query may use.
- `query.max-memory-per-node` - maximum amount of user memory that a query may use on any one machine.
- `query.max-total-memory-per-node` - maximum amount of user and system memory that a query may use on any one machine, where system memory is the memory used during execution by readers, writers, and network buffers, etc.
- `discovery-server.enabled` - Discovery service to find all the nodes in the cluster. Every Presto instance will register itself with the Discovery service on startup. In order to simplify deployment and avoid running an additional service, the Presto coordinator can run an embedded version of the Discovery service. It shares the HTTP server with Presto and thus uses the same port.
- `discovery.uri` -  The URI to the Discovery server. When running the embedded version of Discovery in the Presto coordinator, this should be the URI of the Presto coordinator. This URI must not end in a slash.

There are other additional optional properties to setup features such as:

- Authentication
- Authorization
- Resource Groups

### Presto Catalog Configuration

Presto accesses data via connectors, which are mounted as Presto catalogs. The connector provides all of the schemas and tables inside of the catalog. The Hive connector maps each Hive database to a schema. Catalogs are registered by creating a catalog properties file in the `etc/catalog` directory.

Presto contains a built in TPC-H connector that provides a set of schemas to support the [TPC Benchmark](http://www.tpc.org/information/benchmarks.asp) (TPC-H).

This connector can also be used to test the capabilities and query syntax of Presto without configuring access to an external data source.

To configure the [TPC-H connector](https://prestodb.io/docs/current/connector/tpch.html), create a catalog properties file `etc/catalog/tpch.properties`, name of the catalog properties file will be the name of the catalog exposed in Presto, with the following contents:

```bash
connector.name=tpch
```

Every catalog configuration file requires the connector.name property. Additional properties are determined by the [Presto Connector](https://prestodb.io/docs/current/connector.html) implementations.

Some of the defaults one we will deploy:

- [Black Hole Connector](https://prestodb.io/docs/current/connector/blackhole.html)
- [JMX Connector](https://prestodb.io/docs/current/connector/jmx.html)
- [Memory Connector](https://prestodb.io/docs/current/connector/memory.html)
- [System Connector](https://prestodb.io/docs/current/connector/system.html)
- [TPC-H connector](https://prestodb.io/docs/current/connector/tpch.html)
- [TPCDS Connector](https://prestodb.io/docs/current/connector/tpcds.html)

### Presto Logging Configuration

The optional Presto logging configuration file, `etc/log.properties`, allows setting the minimum log level for named logger hierarchies.

Every logger has a name, which is typically the fully qualified name of the class that uses the logger. Loggers have a hierarchy based on the dots in the name (like Java packages).

For example, consider the following log levels file:

```bash
com.facebook.presto=INFO
```

This would set the minimum level to `INFO` for both `com.facebook.presto.server` and `com.facebook.presto.hive`. The default minimum level is `INFO` (thus the above example does not actually change anything). There are four levels: `DEBUG`, `INFO`, `WARN` and `ERROR`.

### Presto Node Configuration

The node properties file, `etc/node.properties`, contains configuration specific to each node. A node is a single installed instance of Presto on a machine. The following is a minimal example:

```bash
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/presto/data
```

The following are the allowed Presto Node Configuration properties.

- `node.environment` - The name of the environment. All Presto nodes in a cluster must have the same environment name.
- `node.id` - The unique identifier for this installation of Presto. This must be unique for every node. This identifier should remain consistent across reboots or upgrades of Presto.
- `node.data-dir` - The location of the data directory. By default, Presto will store logs and other data here.

### Java Virtual Machine (JVM) Configuration

The JVM config file, `etc/jvm.config`, contains a list of command line options used for launching the Java Virtual Machine (JVM). The format of the file is a list of options, one per line. These options are not interpreted by the shell, so options containing spaces or other special characters should not be quoted.

The following provides a good starting point for creating `etc/jvm.config`:

```bash
-server
-mx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
```

Because an `OutOfMemoryError` will typically leave the JVM in an inconsistent state, we write a heap dump (for debugging) and forcibly terminate the process when this occurs.

The `-mx` option is one of the more important properties in this file. It sets the maximum Heap Space for the JVM, how much memory is available for the Presto process.

## Launcher Scripts

The installation directory contains a couple of launcher scripts, mainly the `bin/launcher` which can be used to:

- `bin/launcher run` -  run Presto as a foreground process. Logs and other output to Presto are written to stdout and stderr.
- `bin/launcher start` -  run Presto as a background daemon process. Logs and other output to Presto are written in `var/log`. This will be located within the installation directly unless you specified a different location in the `etc/node.properties` file.
- `bin/launcher stop` - stop Presto running as a daemon.
- `bin/launcher restart` - stop and start Presto as a daemon.
- `bin/launcher kill` - forcefully stop Presto.
- `bin/launcher status` - obtain the status of Presto.

## PRESTO SERVER LOGS

When running Presto as a background daemon process, logs and other output to Presto are written in `var/log`. This will be located within the installation directly unless you specified a different location in the `etc/node.properties` file.

- `launcher.log` - This log is created by the launcher and is connected to stdout and stderr streams of the server. It will contain a few log messages that occur while the server logging is being initialized and any errors or diagnostics produced by the JVM.
- `server.log` - This is the main log file used by Presto. It will typically contain the relevant information if the server fails during initialization. It is automatically rotated and compressed.
- `http-request.log` - This is the HTTP request log which contains every HTTP request received by the server. It is automatically rotated and compressed.
