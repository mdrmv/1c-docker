FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    locales \
    tzdata \
    procps \
    iproute2 \
    net-tools \
    fontconfig \
    libfreetype6 \
    libglib2.0-0 \
    libgtk2.0-0 \
    libx11-6 \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxslt1.1 \
    libstdc++6 \
    zlib1g \
    imagemagick \
    unixodbc \
    ttf-mscorefonts-installer \
    libgsf-1-114 \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && locale-gen ru_RU.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY build/deb/ /tmp/deb/
RUN apt-get update && \
    dpkg -i /tmp/deb/*.deb || true && \
    apt-get -f install -y && \
    rm -rf /var/lib/apt/lists/* /tmp/deb

RUN mkdir -p /var/lib/1cv8 /var/log/1C && \
    chown -R usr1cv8:grp1cv8 /var/lib/1cv8 /var/log/1C

EXPOSE 1540 1541 1560-1591

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
