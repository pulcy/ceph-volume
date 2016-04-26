FROM alpine:latest

RUN apk add --no-cache bash
ADD ./entrypoint.sh /app/

VOLUME "/data"
ENTRYPOINT ["/app/entrypoint.sh"]
