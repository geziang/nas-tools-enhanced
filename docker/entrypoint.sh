#!/bin/bash

poetry_path="/.poetry"
mkdir -p "${poetry_path}"
python_ver=$(python3 -V | awk '{print $2}')
chown -R "${PUID}":"${PGID}" "${WORKDIR}" /config /usr/lib/chromium "${poetry_path}"
export PATH=${PATH}:/usr/lib/chromium

execute() {
  echo "$1"
  exec su-exec "${PUID}":"${PGID}" $1
}

export POETRY_VIRTUALENVS_PATH="${poetry_path}/venv"
export POETRY_CACHE_DIR="${poetry_path}/cache"

cd ${WORKDIR}

# 自动更新
if [ "${NASTOOL_AUTO_UPDATE}" = "true" ]; then
    echo "更新程序..."
    git remote set-url origin "${REPO_URL}" &> /dev/null

    git clean -dffx
    git fetch origin ${NASTOOL_BRANCH}
    git reset --hard $(git tag --sort=-v:refname | head -1)

    if [ $? -eq 0 ]; then
        echo "更新成功..."
    else
        echo "更新失败..."
    fi
else
    echo "程序自动升级已关闭，如需自动升级请在创建容器时设置环境变量：NASTOOL_AUTO_UPDATE=true"
fi

echo "以PUID=${PUID}，PGID=${PGID}的身份启动程序..."

umask "${UMASK}"
chmod +x ./start.sh
execute "./start.sh"
