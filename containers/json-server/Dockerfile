FROM alpine as alpine

LABEL name="json-server"
LABEL description="Small json server"

ENV PYTHONUNBUFFERED=1

RUN apk add --update --quiet --no-cache \
      bash bash-completion vim nano jq \
      httpie curl wget \
      netcat-openbsd net-tools bind-tools \
      python3

ADD ./server.py /server.py
RUN chmod +x /server.py

ENV HTTP_PORT=8080
ENV ZONE=myzone
ENV REGION=myregion
ENV MSG=mymessage
EXPOSE 8080

WORKDIR /server
ENTRYPOINT ["/server.py"]
