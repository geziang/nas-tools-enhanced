FROM python:3.10.10-slim-buster
ENV NASTOOL_BRANCH="dev"
RUN apt-get update -y \
    && apt-get install wget -y \
    && apt-get install -y $(echo $(wget --no-check-certificate -qO- https://raw.githubusercontent.com/sgpublic/nas-tools-enhanced/${NASTOOL_BRANCH}/package_list.txt)) \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && curl https://rclone.org/install.sh | bash \
    && if [ "$(uname -m)" = "x86_64" ]; then ARCH=amd64; elif [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi \
    && curl https://dl.min.io/client/mc/release/linux-${ARCH}/mc --create-dirs -o /usr/bin/mc \
    && chmod +x /usr/bin/mc \
    && pip install --upgrade pip setuptools wheel \
    && pip install cython \
    && pip install poetry \
    && rm -rf /tmp/* /root/.cache /var/cache/apk/*
RUN set -ex; \
    curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
    fetch_deps='gcc libc-dev'; \
    apt-get update; \
    apt-get install -y --no-install-recommends $fetch_deps; \
    rm -rf /var/lib/apt/lists/*; \
    gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
    chown root:root /usr/local/bin/su-exec; \
    chmod 0755 /usr/local/bin/su-exec; \
    rm /usr/local/bin/su-exec.c; \
    apt-get purge -y --auto-remove $fetch_deps
ENV LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    NASTOOL_CONFIG="/config/config.yaml" \
    NASTOOL_AUTO_UPDATE="false" \
    NASTOOL_BRANCH="main" \
    PS1="\u@\h:\w \$ " \
    REPO_URL="https://github.com/sgpublic/nas-tools-enhanced.git" \
    PUID=0 \
    PGID=0 \
    UMASK=000 \
    WORKDIR="/nas-tools-enhanced"
WORKDIR ${WORKDIR}
RUN echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=524288' >> /etc/sysctl.conf \
    && git config --global pull.ff only \
    && git clone -b ${NASTOOL_BRANCH} ${REPO_URL} ${WORKDIR} --depth=1 --recurse-submodule \
    && git config --global --add safe.directory ${WORKDIR}
EXPOSE 3000
VOLUME ["/config"]
ENTRYPOINT ["/nas-tools-enhanced/docker/entrypoint.sh"]
