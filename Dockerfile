FROM python:3-alpine

RUN apk add --update tini su-exec && apk add python3 \
          python3-dev \
          build-base \
          libffi-dev \
          ca-certificates \
          openssl \
          apache2-utils

RUN pip install --upgrade pip
RUN pip install passlib bcrypt
RUN pip install radicale

# User with no home, no password
RUN adduser -s /bin/false -D -H radicale

COPY config /radicale
RUN mkdir -p /radicale/data && chown radicale /radicale/data
RUN htpasswd -bc /radicale/users sjtudoit sjtudoit
WORKDIR /radicale/data

VOLUME /radicale/data
EXPOSE 5232

# Tiny starts our entrypoint which starts Radicale
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]
CMD ["radicale", "--config", "/radicale/config"]
