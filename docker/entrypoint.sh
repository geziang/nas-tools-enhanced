#!/bin/sh

cd ${WORKDIR}

# 自动更新
if [ "${NASTOOL_AUTO_UPDATE}" = "true" ]; then
    echo "更新程序..."
    git remote set-url origin "${REPO_URL}" &> /dev/null
    echo "windows/" > .gitignore

    git clean -dffx
    git fetch origin master
    git reset --hard $(git tag --sort=-v:refname | head -1)

    if [ $? -eq 0 ]; then
        echo "更新成功..."
        # Python依赖包更新
        python -m poetry install
    else
        echo "更新失败，继续使用旧的程序来启动..."
    fi
else
    echo "程序自动升级已关闭，如需自动升级请在创建容器时设置环境变量：NASTOOL_AUTO_UPDATE=true"
fi

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."

mkdir -p /.local
mkdir -p /.pm2
chown -R "${PUID}":"${PGID}" "${WORKDIR}" /config /usr/lib/chromium /.local /.pm2
export PATH=${PATH}:/usr/lib/chromium

umask "${UMASK}"
exec su-exec "${PUID}":"${PGID}" "$(which dumb-init)" "$(which pm2-runtime)" start run.py -n NAStool --interpreter python3
