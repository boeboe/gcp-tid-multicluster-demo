FROM ubuntu:focal

LABEL name="json-client"
LABEL description="Small json client"

WORKDIR /

RUN apt-get update -y && apt-get install -y \
  bash bash-completion vim nano jq \
  httpie curl wget tcpdump ssldump \
  netcat-openbsd net-tools dnsutils \
  && rm -rf /var/lib/apt/lists/*

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
