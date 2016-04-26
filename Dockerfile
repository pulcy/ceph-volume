FROM ubuntu:latest

ADD ./entrypoint.sh /app/

VOLUME "/data"
ENTRYPOINT ["/app/entrypoint.sh"]
