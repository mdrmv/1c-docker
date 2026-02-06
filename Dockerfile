FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    locales tzdata \
    net-tools iproute2 procps \
    netcat-openbsd \
    libfreetype6 libglib2.0-0 libx11-6 libxext6 libxi6 libxrender1 libxslt1.1 \
    libstdc++6 zlib1g \
    gosu \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen ru_RU.UTF-8 && update-locale LANG=ru_RU.UTF-8
ENV LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8

COPY build/deb/ /tmp/deb/
RUN apt-get update && \
    dpkg -i /tmp/deb/*.deb || true && \
    apt-get -f install -y && \
    rm -rf /var/lib/apt/lists/* /tmp/deb

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1540 1541 1560-1591

ENTRYPOINT ["/entrypoint.sh"]
