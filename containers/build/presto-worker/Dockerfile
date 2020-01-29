FROM openjdk:8

ARG MIRROR=https://repo1.maven.org/maven2/com/facebook/presto
ARG VERSION=0.230
ARG DISTRO_NAME=presto-server-$VERSION

ENV PRESTO_ENV=docker \
    PRESTO_HEAP_SIZE=2G \
    PRESTO_DATA_DIR=/data \
    PRESTO_HOME=/$DISTRO_NAME \
    PRESTO_CFG_DIR=/$DISTRO_NAME/etc \
    PRESTO_CATALOG_DIR=/$DISTRO_NAME/etc/catalog \
    PRESTO_QUERY_MAX_MEMORY=1GB \
    PRESTO_QUERY_MAX_MEMORY_PER_NODE=1GB \
    PRESTO_QUERY_MAX_TOTAL_MEMORY_PER_NODE=1GB \
    PATH=$PATH:/$DISTRO_NAME/bin

RUN set -eux && \
    groupadd -r presto --gid=1000 && \
    useradd -r -g presto --uid=1000 presto && \
    wget "$MIRROR/presto-server/$VERSION/$DISTRO_NAME.tar.gz" -O "$DISTRO_NAME.tar.gz" && \
	tar xvzf "$DISTRO_NAME.tar.gz" && \
    rm -rf  "$DISTRO_NAME.tar.gz" && \
    mkdir -p $PRESTO_DATA_DIR $PRESTO_CFG_DIR && \
    chown -R presto:presto "/$DISTRO_NAME" "$PRESTO_DATA_DIR" "$PRESTO_CFG_DIR"

WORKDIR $PRESTO_HOME
VOLUME ["$PRESTO_DATA_DIR"]
EXPOSE 8080
USER presto

COPY --chown=presto:presto catalog/ $PRESTO_HOME/default/catalog
COPY --chown=presto:presto docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["launcher", "run"]