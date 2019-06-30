FROM ubuntu:18.04

ARG GEOIPUPDATE_VERSION
ENV UPDATER_ROOT=/opt/geoip
ENV GEOIP_DIRECTORY="${UPDATER_ROOT}/databases"
ENV GEOIP_ACCOUNT_ID="0"
ENV GEOIP_LICENSE_KEY="000000000000"
ENV GEOIP_PRODUCT_IDS="GeoLite2-City"
ENV INITIALIZE_ONLY=false

RUN mkdir "${UPDATER_ROOT}" && mkdir "${GEOIP_DIRECTORY}"
WORKDIR "${UPDATER_ROOT}"
ADD MaxMindPuller/pull.sh "${UPDATER_ROOT}"

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget "https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE_VERSION}/geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64.tar.gz"
# Extract the binary and delete the tarball to minimize image size
RUN tar zxvf "geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64.tar.gz" && \
  rm "geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64.tar.gz" && \
  cp "geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64/geoipupdate" . && \
  rm -rf "geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64"

# We do not want to run as root
RUN groupadd -r updater && useradd -r -g updater updater
RUN chown -R "updater:echo" "${UPDATER_ROOT}"
# Make only the entry script executable
RUN chmod 0740 "${UPDATER_ROOT}/pull.sh"
# Switch to non-root user
USER updater

ENTRYPOINT ["./pull.sh"]