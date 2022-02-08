FROM alpine as alpine

LABEL name="json-client"
LABEL description="Small json client"

WORKDIR /

RUN apk add --update --quiet --no-cache \
      bash bash-completion vim nano jq \
      httpie curl wget \
      netcat-openbsd net-tools bind-tools

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
