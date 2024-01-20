FROM python:3.11.7-slim-bookworm

ENV IN_DOCKER=True \
    TZ=UTC \
    LANGUAGE=en_US:en \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    npm_config_loglevel=error \
    ARCHIVEBOX_USER="archivebox" \
    DEFAULT_PUID=911 \
    DEFAULT_PGID=911 \
    PATH="/app/node_modules/.bin:$PATH"

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "errtrace", "-o", "nounset", "-c"]

# Create non-privileged user for archivebox and chrome
RUN echo "[*] Setting up $ARCHIVEBOX_USER user uid=${DEFAULT_PUID}..." \
    && groupadd --system $ARCHIVEBOX_USER \
    && useradd --system --create-home --gid $ARCHIVEBOX_USER --groups audio,video $ARCHIVEBOX_USER \
    && usermod -u "$DEFAULT_PUID" "$ARCHIVEBOX_USER" \
    && groupmod -g "$DEFAULT_PGID" "$ARCHIVEBOX_USER"
    # DEFAULT_PUID and DEFAULT_PID are overriden by PUID and PGID in /bin/docker_entrypoint.sh at runtime
    # https://docs.linuxserver.io/general/understanding-puid-and-pgid

RUN echo "[+] Installing APT base system dependencies..." \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends \
        ca-certificates curl ripgrep \
        gosu cron procps \
    && rm -rf /var/lib/apt/lists/*

# Install chromium browser using playwright
RUN echo "[+] Installing Browser binary dependencies to /browsers..." \
    && pip install playwright \
    && playwright install --with-deps chromium \
    && export CHROME_BINARY="$(python -c 'from playwright.sync_api import sync_playwright; print(sync_playwright().start().chromium.executable_path)')" \
    && ln -s "$CHROME_BINARY" /usr/bin/chromium-browser \
    && mkdir -p "/home/${ARCHIVEBOX_USER}/.config/chromium/Crash Reports/pending/" \
    && chown -R $ARCHIVEBOX_USER "/home/${ARCHIVEBOX_USER}/.config" \
    && mkdir -p /browsers \
    && chown -R $ARCHIVEBOX_USER /browsers

WORKDIR /app
COPY "./archivebox-0.7.2/archivebox/package.json" "./package-lock.json" .
RUN apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends gnupg2 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_21.x nodistro main" >> /etc/apt/sources.list.d/nodejs.list \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && apt-get install -qq -y --no-install-recommends nodejs npm \
    # update npm to latest
    && npm i -g npm --cache /root/.npm \
    && npm ci --prefer-offline --no-audit --cache /root/.npm \
    && apt-get purge -y --auto-remove gnupg2 npm \
    && rm -rf /var/lib/apt/lists/*

# do we have yt-dlp on PATH after this?
COPY "./archivebox-0.7.2/requirements.txt" .
RUN pip install -r requirements.txt

COPY "./archivebox-0.7.2" .
RUN pip install .

WORKDIR /data
VOLUME /data
EXPOSE 8000

COPY "./docker_entrypoint.sh" /
ENTRYPOINT ["/docker_entrypoint.sh"]
CMD ["archivebox", "server", "--quick-init", "0.0.0.0:8000"]
