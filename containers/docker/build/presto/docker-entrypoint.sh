#!/bin/bash
set -e

if [ ${DISCOVERY_SERVER_IP} == 'localhost' ] && [ ${PRESTO_ROLE} == 'worker' ]; then
    echo "If the role is worker, DISCOVERY_SERVER_IP must be set to other than localhost!"
    exit
fi

if [ ! -f "$PRESTO_CFG_DIR/config.properties" ]; then
    CONFIG_PROPERTIES="$PRESTO_CFG_DIR/config.properties"
    {
        if [ ${PRESTO_ROLE} != 'worker' ]; then
            echo "coordinator=true"
        else
            echo "coordinator=false"
        fi
        if [ ${PRESTO_ROLE} == 'standalone' ]; then
            echo "node-scheduler.include-coordinator=true"
        else
            echo "node-scheduler.include-coordinator=false"
        fi
        echo "http-server.http.port=8080"
        echo "query.max-memory=$PRESTO_QUERY_MAX_MEMORY"
        echo "query.max-memory-per-node=$PRESTO_QUERY_MAX_MEMORY_PER_NODE"
        echo "query.max-total-memory-per-node=$PRESTO_QUERY_MAX_TOTAL_MEMORY_PER_NODE"
        if [ ${PRESTO_ROLE} != 'worker' ]; then
            echo "discovery-server.enabled=$IS_DISCOVERY_INTERNAL"
        fi
        echo "discovery.uri=http://$DISCOVERY_SERVER_IP:$DISCOVERY_SERVER_PORT"
    } >> "$CONFIG_PROPERTIES"
fi

if [ ! -f "$PRESTO_CFG_DIR/jvm.config" ]; then
    JVM_CONFIG="$PRESTO_CFG_DIR/jvm.config"
    {
        echo "-server"
        echo "-Xmx$PRESTO_HEAP_SIZE"
        echo "-XX:-UseBiasedLocking"
        echo "-XX:+UseG1GC"
        echo "-XX:G1HeapRegionSize=32M"
        echo "-XX:+ExplicitGCInvokesConcurrent"
        echo "-XX:+HeapDumpOnOutOfMemoryError"
        echo "-XX:+UseGCOverheadLimit"
        echo "-XX:+ExitOnOutOfMemoryError"
        echo "-XX:ReservedCodeCacheSize=256M"
        echo "-Djdk.attach.allowAttachSelf=true"
        echo "-Djdk.nio.maxCachedBufferSize=2000000"
    } >> "$JVM_CONFIG"
fi

if [ ! -f "$PRESTO_CFG_DIR/node.properties" ]; then
    NODE_PROPERTIES="$PRESTO_CFG_DIR/node.properties"
    {
        echo "node.environment=$PRESTO_ENV"
        echo "node.id=$HOSTNAME"
        echo "node.data-dir=$PRESTO_DATA_DIR"
    } >> "$NODE_PROPERTIES"
fi

if [ ! -d $PRESTO_CATALOG_DIR ]; then
    ln -s $PRESTO_HOME/default/catalog $PRESTO_HOME/etc/
fi

exec "$@"