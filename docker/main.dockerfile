# syntax = docker/dockerfile:experimental

FROM python:3.10-slim-bullseye as builder

ENV NASTOOL_BRANCH="main-my"

RUN apt-get update && apt-get install -y gcc g++ curl wget && \
    apt-get install -y $(echo $(wget --no-check-certificate -qO- https://raw.githubusercontent.com/geziang/nas-tools-enhanced/${NASTOOL_BRANCH}/package_list.txt))

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && apt-get install --reinstall libc6-dev -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN pip install --upgrade pip setuptools wheel && \
    pip install cython poetry && \
    pip install -r https://github.com/geziang/nas-tools-enhanced/raw/${NASTOOL_BRANCH}/requirements.txt

RUN set -ex; \
    curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
    gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
    chown root:root /usr/local/bin/su-exec; \
    chmod 0755 /usr/local/bin/su-exec; \
    rm /usr/local/bin/su-exec.c


FROM python:3.10-slim-bullseye

# Copy pre-built packages from builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY --from=builder /usr/local/bin/su-exec /usr/local/bin/su-exec

RUN set -ex; \
    chown root:root /usr/local/bin/su-exec; \
    chmod 0755 /usr/local/bin/su-exec

ENV NASTOOL_BRANCH="main-my"
RUN apt-get update -y \
    && apt-get install curl wget -y \
    && apt-get install -y $(echo $(wget --no-check-certificate -qO- https://raw.githubusercontent.com/geziang/nas-tools-enhanced/${NASTOOL_BRANCH}/package_list.txt)) \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && curl https://rclone.org/install.sh | bash \
    && ARCH=arm \
    && curl https://dl.min.io/client/mc/release/linux-${ARCH}/mc --create-dirs -o /usr/bin/mc \
    && chmod +x /usr/bin/mc \
    && pip install --upgrade pip \
    && pip install cython poetry \
    && rm -rf /tmp/* /root/.cache /var/cache/apk/*
    
ENV LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    NASTOOL_CONFIG="/config/config.yaml" \
    NASTOOL_AUTO_UPDATE="false" \
    NASTOOL_BRANCH="main-my" \
    PS1="\u@\h:\w \$ " \
    REPO_URL="https://github.com/geziang/nas-tools-enhanced.git" \
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
