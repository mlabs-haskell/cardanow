# syntax=docker/dockerfile:1

FROM debian:bookworm-slim

RUN apt-get update && apt-get upgrade
RUN apt-get install -y wget netbase

ARG CARDANO_NODE_VERSION=8.1.2
RUN wget -c https://github.com/IntersectMBO/cardano-node/releases/download/${CARDANO_NODE_VERSION}/cardano-node-${CARDANO_NODE_VERSION}-linux.tar.gz -O - | tar -xz -C /usr/local/bin

ARG MITHRIL_CLI_VERSION=2347.0
RUN wget -c https://github.com/input-output-hk/mithril/releases/download/${MITHRIL_CLI_VERSION}/mithril-${MITHRIL_CLI_VERSION}-linux-x64.tar.gz -O - | tar -xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/mithril-client

COPY ./bin/entrypoint /usr/local/bin

COPY --from=config mithril-configs/ /opt/cardano/mithril-configs
COPY --from=config cardano-configurations/network /opt/cardano/network

ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
