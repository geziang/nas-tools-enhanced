from app.utils import SystemUtils

APP_VERSION = SystemUtils.execute('git describe --abbrev=10 --tags --always')
